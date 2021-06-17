//
//  PerformanceViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import "PerformanceScrollingViewController.h"
#import "ScrollingPngView.h"
#import "ImageTilingView.h"
#import "Score.h"
#import "Page.h"
#import "PerformanceAnnotationView.h"
#import "EditorViewController.h"
#import "Measure.h"
#import "TempoSelectViewController.h"
#import "CountInView.h"
#import "ModePickerView.h"
#import "AirTurnTextView.h"
#import "AirTurnBpmView.h"
#import "TempoToolbarView.h"
#import "ALView+PureLayout.h"
#import "MetricsManager.h"
#import "HelpViewPopOverViewController.h"

@implementation PerformanceScrollingViewController

#pragma mark - Lifecycle

- (id)initWithSet:(Set *)theSet
            score:(Score *)theScore
             page:(Page *)thePage
  performanceMode:(PerformanceMode)thePerformanceMode
{
	if ((self = [super initWithSet:theSet 
                             score:theScore 
                              page:thePage 
                  presentingObject:nil
                   dismissSelector:NULL
                 performanceMode:thePerformanceMode])) 
    {
        self.performanceManager = [[PerformanceManager alloc] initWithScore:theScore
                                                                   delegate:self
                                                            performanceMode:thePerformanceMode
                                                    playtimeCalculationOnly:NO];
        [self.performanceManager createTimelineWithScrollPositions:YES];
        self.scrollToPoint = CGPointZero;
        
        // Register to receive kEditorWillDismissWithChangesNotification notifications
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(observeEditorDismissalWithChanges)
                       name:kEditorWillDismissWithChangesNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(observeWillPresentEditor)
                       name:kWillPresentEditorNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(observePerformanceControllerWillPresentHelpView)
                       name:kPerformanceControllerWillPresentHelpViewNotification 
                     object:nil];
        [center addObserver:self
                   selector:@selector(observeApplicationWillResignActive)
                       name:UIApplicationWillResignActiveNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(observePerformanceControllerDidChangeScore)
                       name:kPerformanceControllerDidChangeScoreNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(observePerformanceControllerWillPresentScorePicker)
                       name:kPerformanceControllerWillPresentScorePickerNotification
                     object:nil];
        
    }
    return self;
}

- (void)viewDidLoad 
{       
    [super viewDidLoad];
    
    self.pageHostingView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.performanceScrollView addSubview:self.pageHostingView];
    
    // Set start measure to first measure in timeline
    if ([self.performanceManager.timeline count] > 0) {
        self.performanceManager.startMeasure = self.performanceManager.timeline[0];
    }
    [self highlightStartMeasure]; // removes highlight if start measure is nil
    
    self.activeMeasureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"measure_indicator"]];
    self.activeMeasureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin;
    self.activeMeasureIndicator.alpha = kMeasureIndicatorAlpha;
    
    self.startMeasureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start_measure_indicator"]];
    self.startMeasureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin;
    self.startMeasureIndicator.alpha = kMeasureIndicatorAlpha;

    // Create toolbar items
    self.playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                    target:self
                                                                    action:@selector(play)];
    self.playButton.style = UIBarButtonItemStylePlain;
    
    self.pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause)];
    self.pauseButton.style = UIBarButtonItemStylePlain;
    
    self.rewindButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                      target:self
                                                                      action:@selector(rewind)];
    self.rewindButton.style = UIBarButtonItemStylePlain;
        
    self.stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                  target:self
                                                                  action:@selector(stop)];
    self.stopItem.style = UIBarButtonItemStylePlain;
    
    self.chooseStartMeasureItem = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"buttonChooseStartMeasure", nil)
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(chooseStartMeasure)];
    // Tempo item
    [[NSBundle mainBundle] loadNibNamed:@"TempoToolbarView"
                                  owner:self
                                options:nil];
    self.tempoToolbarView.bpmLabel.text = [NSString stringWithFormat:kMetronomeFormatString, [self.score.metronomeBpm intValue]];
    self.tempoToolbarView.noteValueImageView.image = [Helpers noteValueImageForNoteValueString:self.score.metronomeNoteValue
                                                                                imageSpecifier:NoteValueImageSpecifierPetrol];
    PerformanceScrollingViewController *__weak weakSelf = self;
    self.tempoToolbarView.didReceiveTouchBlock = ^void(TempoToolbarView *sender) {
        if (nil != self.performanceManager.startMeasure) {
            [weakSelf.performanceManager stop];
            [weakSelf removeMeasureHighlight];

            if (nil == self.tempoSelectPresentationController) {
                TempoSelectViewController *controller = [[TempoSelectViewController alloc] initWithScore:weakSelf.score
                                                                                              completion:^(NSDictionary *newTempo)
                  {
                      NSString *noteValue = newTempo[kEditorActiveTempoNoteValue];
                      NSNumber *bpm = newTempo[kEditorActiveTempoBpm];

                      weakSelf.tempoToolbarView.bpmLabel.text = [NSString stringWithFormat:kMetronomeFormatString, [bpm intValue]];
                      weakSelf.tempoToolbarView.noteValueImageView.image = [Helpers noteValueImageForNoteValueString:noteValue
                                                                                                  imageSpecifier:NoteValueImageSpecifierPetrol];
                  }];
                UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                aNavigationController.navigationBar.translucent = NO;
                aNavigationController.modalPresentationStyle = UIModalPresentationPopover;
                [weakSelf presentViewController:aNavigationController
                                       animated:YES
                                     completion:nil];
                weakSelf.tempoSelectPresentationController = aNavigationController.popoverPresentationController;
                weakSelf.tempoSelectPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                weakSelf.tempoSelectPresentationController.barButtonItem = weakSelf.tempoItem;
                weakSelf.tempoSelectPresentationController.delegate = weakSelf;
            }
        }else {
            [weakSelf showEnterMeasurePrompt];
        }
    };
    self.tempoItem = [[UIBarButtonItem alloc] initWithCustomView:self.tempoToolbarView];
    
    self.pagePickerDismisser = [Helpers singleFingerTabRecognizerwithTarget:self
                                                                      action:@selector(dismissPagePicker)
                                                                    delegate:nil];
    [self.performanceScrollView addGestureRecognizer:self.pagePickerDismisser];

    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        self.startMeasureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(observeStartMeasureLongPress:)];
        [self.performanceScrollView addGestureRecognizer:self.startMeasureRecognizer];
    }else if (PerformanceModeSimpleScroll == self.performanceMode) {
        self.scrollSpeedSelectorViewController = [[ScrollSpeedSelectorViewController alloc] initWithNibName:@"ScrollSpeedSelectorViewController"
                                                                                                     bundle:nil];
        self.scrollSpeedSelectorViewController.score = self.score; // Sets label and _scrollSpeed
        [self.view addSubview:self.scrollSpeedSelectorViewController.view];
        [self.view bringSubviewToFront:self.scrollSpeedSelectorViewController.view];
        [self.scrollSpeedSelectorViewController.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing
                                                                      withInset:7.0f];
        [self.scrollSpeedSelectorViewController.view autoPinEdge:ALEdgeTop
                                                          toEdge:ALEdgeBottom
                                                          ofView:self.topToolbar
                                                      withOffset:7.0f];
    }
    
    [self.topToolbar setItems:[self topToolbarItems]];
    [self.bottomToolbar setItems:[self bottomToolbarItems]];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setupCanvas];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!CGPointEqualToPoint(self.scrollToPoint, CGPointZero)) {
        [self scrollToMeasureAtPoint:self.scrollToPoint
                            animated:NO
                      scrollPosition:PerformanceScrollPositionTop];
        self.scrollToPoint = CGPointZero;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (PerformanceModeAdvancedScroll == self.performanceMode && nil == self.performanceManager.startMeasure) {
        [self showEnterMeasurePrompt];
    }
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size
          withTransitionCoordinator:coordinator];

    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:NO];
    }
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        self.canvasDidSetup = NO;
        [self.view setNeedsLayout]; // calls through to didLayoutSubview which in turns calls setupCanvas and drawPages
    } completion:nil];
}

#pragma mark - Metrics

- (void)setupCanvas
{
    self.performanceScrollView.maximumZoomScale = 1.0;
    self.performanceScrollView.minimumZoomScale = [self contentFrame].size.width /
            [MetricsManager scoreWidthAtFullScale];

    if (!self.canvasDidSetup) {
        self.performanceScrollView.zoomScale = [self defaultZoomScale];
        self.canvasDidSetup = YES;  // this flag blocks calls to drawPages through zoom scale changes
    }

    CGSize canvasSize = CGSizeMake(
            roundf([MetricsManager scoreWidthAtFullScale] * self.performanceScrollView.zoomScale),
            roundf([self.score canvasHeight] * self.performanceScrollView.zoomScale)
    );
    self.pageHostingView.frameSize = canvasSize;
    self.performanceScrollView.contentSize = canvasSize;
    [self highlightStartMeasure];
    [self drawPages];
}

- (CGFloat)defaultZoomScale
{
    return [self contentFrame].size.width / [MetricsManager scoreWidthAtFullScale];
}

- (CGRect)contentFrame
{
    return self.view.bounds;
}

- (CGRect)scrollViewBoundsInPageCoordinates
{
    CGFloat factor = self.performanceScrollView.maximumZoomScale / self.performanceScrollView.zoomScale;
    return CGRectMake(
            roundf(self.performanceScrollView.bounds.origin.x * factor),
            roundf(self.performanceScrollView.bounds.origin.y * factor),
            roundf(self.performanceScrollView.frameWidth * factor),
            roundf(self.performanceScrollView.frameHeight * factor)
    );
}


- (CGRect)frameForPage:(Page *)thePage
{
    CGFloat y = [thePage positionOnCanvas];
    y += [MetricsManager scrollingPagePadding] * ([thePage.number intValue] - 1);
    return CGRectMake(
            0,
            y,
            [thePage width],
            [thePage height]
    );
}

#pragma mark - Scroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.pageHostingView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self drawPages];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	[self drawPages]; // solves pages disappearing erratically during zooming
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        if ([self.performanceManager isPlaying]) {
            [self placeCurrentMeasureHighlight];
        }
        [self highlightStartMeasure];
    }
}

#pragma mark - Page Display

- (void)drawPages
{
    if (nil == self.score || !self.canvasDidSetup) {
        return;
    }

    // When the pages are shown fit to width the zoom scale is around .6
    // The pages are placed onto the canvas at full frame sizes and subsequently 
    // shrunk by applying the zoom scale.
    
    // Adjust the visible bounds of the scrollview so that it maps to the
    // coordinate space of the (full size) pages.
    CGRect visibleBounds = [self scrollViewBoundsInPageCoordinates];
    CGFloat visibleBoundsMinY = visibleBounds.origin.y;

	if (visibleBoundsMinY < 0) {
		return;
	}
	NSArray *pagesAsc = [self orderedPagesAsc], *pagesDesc = [self orderedPagesDesc];
    CGFloat visibleBoundsMidY = CGRectGetMidY(visibleBounds);
	NSUInteger firstNeededPageIndex = 0, lastNeededPageIndex = 0;
	
	// Find first page
	for (NSUInteger i = 0; i < [pagesAsc count]; i++) {
		Page *page = pagesAsc[i];
		Page *nextPage = ( (i + 1) < [pagesAsc count] ) ? pagesAsc[i + 1] : nil;
		
		CGFloat pagePositionOnCanvas = [page positionOnCanvas] + [MetricsManager scrollingPagePadding] * i;
		CGFloat nextPagePositionOnCanvas = CGFLOAT_MAX;
		if (nil != nextPage) {
            nextPagePositionOnCanvas = [nextPage positionOnCanvas] + [MetricsManager scrollingPagePadding] * (i + 1);
		}
		if (visibleBoundsMinY >= pagePositionOnCanvas){
			if (visibleBoundsMinY < nextPagePositionOnCanvas) {
				firstNeededPageIndex = i;
				break;
			}
		}
	}
	
	// Find last page
	for (Page *page in pagesDesc) {
		CGFloat pagePositionOnCanvas = [page positionOnCanvas] +
                [MetricsManager scrollingPagePadding] *
                        ([page.number intValue] -1);
        if (pagePositionOnCanvas <= CGRectGetMaxY(visibleBounds)) {
			lastNeededPageIndex = [page.number unsignedIntegerValue] -1;
			break;
		}
	}
	//NSLog(@"first needed page index: %d, last needed page index: %d", firstNeededPageIndex, lastNeededPageIndex);

    // Recycle no-longer-visible pages 
    for (ScrollingPngView *pngPage in self.visiblePages) {
        if (pngPage.index < firstNeededPageIndex || pngPage.index > lastNeededPageIndex) {
            [self.recycledPages addObject:pngPage];
            [pngPage removeFromSuperview];
            [pngPage invalidate];
        }
    }
    [self.visiblePages minusSet:self.recycledPages];
#if kAvoidRecyclingScrollingPerformance
    [self.recycledPages removeAllObjects];
#endif
	
    NSUInteger newActivePageIndex = UINT_MAX;
	// add missing pages and set active page
    for (NSUInteger index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        
        // Add missing pages
        if (![self isDisplayingPageForIndex:index]) {
            ScrollingPngView *pngPage; 
#if kAvoidRecyclingScrollingPerformance
            pngPage = nil;
#else
            pngPage = (ScrollingPngView *) [self dequeueRecycledPage];
#endif
            if (pngPage == nil) {
                pngPage = [[ScrollingPngView alloc] init];
            }
			[self configurePage:pngPage
                       forIndex:index];
            [pngPage willDisplay];
            [self.pageHostingView addSubview:pngPage];
            [self.visiblePages addObject:pngPage];
        }
        
        // Set active page
        Page *currentPage = [self orderedPagesAsc][index];
        CGFloat positionOnCanvas = [currentPage positionOnCanvas];
        if (positionOnCanvas < visibleBoundsMidY) {
            newActivePageIndex = [currentPage.number unsignedIntegerValue] - 1;
        }
    }
    if (newActivePageIndex < [pagesAsc count]) {
        self.activePage = [self orderedPagesAsc][newActivePageIndex];
    }
    self.pagePickerItem.title = [NSString stringWithFormat:MyLocalizedString(@"currentPageIndicator", nil),
                                          newActivePageIndex + 1, [pagesAsc count]];
    if (nil != self.pagePickerScrollView) {
        self.pagePickerScrollView.activePage = self.activePage;
        [self.pagePickerScrollView viewControllerPageSelectionDidChange];
    }
}

- (void)configurePage:(ScrollingPngView *)pngPage 
			 forIndex:(NSUInteger)index
{
	Page *page = [self orderedPagesAsc][index];
    CGRect pngViewFrame = [self frameForPage:page];
    pngPage.index = index;
	pngPage.page = page;
	pngPage.frame = pngViewFrame;
    pngPage.tilingView.index = index;
    pngPage.tilingView.contentScaleFactor = 1.0;
	pngPage.tilingView.frameSize = pngViewFrame.size;
    pngPage.tilingView.page = page;
    pngPage.tilingView.annotationView.page = page;
    pngPage.tilingView.annotationView.frameSize = pngViewFrame.size;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
	for (ScrollingPngView *page in self.visiblePages) {
		if (page.index == index) {
			return YES;
		}
	}
	return NO;
}

- (ScrollingPngView *)dequeueRecycledPage
{
    ScrollingPngView *page = [self.recycledPages anyObject];
    if (nil != page) {
        [self.recycledPages removeObject:page];
    }
    return page;
}

- (void)showPage:(Page *)thePage animated:(BOOL)animated
{
    CGRect theRect = [self frameForPage:thePage];
    theRect.origin.y *= self.performanceScrollView.zoomScale;
    // Make the top edge visible
    theRect.size.width = [self contentFrame].size.width;
    theRect.size.height = [self contentFrame].size.height;
    [self.performanceScrollView scrollRectToVisible:theRect
                                           animated:animated];
}

- (void)refreshAnnotations
{
    [super refreshAnnotations];
    for (ScrollingPngView *page in self.visiblePages) {
        [page willDisplay];
    }
}

#pragma mark - Start Measure Picker

- (void)chooseStartMeasure
{
    [self dismissPopovers:NO];

    if ([self.performanceManager.timeline count] ==  0) {
        [self showEnterMeasurePrompt];
        return;
    }
    
    [self.performanceManager stop];
    [self removeMeasureHighlight];
    
    EditorViewController *editor = [[EditorViewController alloc] initWithScore:self.score
                                                                          page:self.activePage
                                                      editorViewControllerType:EditorViewControllerTypeStartMeasure
                                                                  dismissBlock:^(Measure *startMeasure)
    {
        self.performanceManager.startMeasure = startMeasure;
        // Save this position so we can scroll to it once the view appears
        self.scrollToPoint = [self.performanceManager measurePositionOnCanvas:startMeasure];
    }];
    editor.activeStartMeasure = [self.performanceManager startMeasure];
    [self.navigationController pushViewController:editor
                                         animated:YES];
}

#pragma mark - Performance Controls

- (void)play {
    [self.airTurnTextView becomeFirstResponder];
    
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
    }

    [self dismissPopovers:YES];
    
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        if (nil != self.performanceManager.startMeasure) {
            if (![self.performanceManager isPlaying]) {
                // Make start measure visible.
                CGPoint position = [self.performanceManager measurePositionOnCanvas:self.performanceManager.startMeasure];
                [self scrollToMeasureAtPoint:position
                                    animated:YES
                              scrollPosition:PerformanceScrollPositionTop];
                [self.performanceManager play];
                if (0 == [[NSUserDefaults standardUserDefaults] boolForKey:kMetronomeCountInNumberOfBars]) {
                    [self hideToolbars];
                }
            }
        }else {
            [self showEnterMeasurePrompt];
        }
    }else {
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.topToolbar.items];
        if ([items containsObject:self.playButton]) {
            items[[items indexOfObject:self.playButton]] = self.pauseButton;
            [self.topToolbar setItems:items animated:NO];
        }
        [self hideToolbars]; 
        [self.performanceManager play];
    } 
}

- (void)prepareCountInView
{
    [[NSBundle mainBundle] loadNibNamed:@"CountInView" owner:self options:nil];
    self.countInView.hidden = YES;
    self.countInView.center = self.view.center;
    [self.view addSubview:self.countInView];
}

- (void)updateCountInViewWithBeat:(NSNumber *)beat
{
    self.countInView.hidden = NO;
    self.countInView.countInLabel.text = [NSString stringWithFormat:@"%d", [beat intValue]];
}

- (void)finishCountIn
{
    [self removeCountInView];
    [self hideToolbars];
}

- (void)pause
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.topToolbar.items];
    if ([items containsObject:self.pauseButton]) {
        items[[items indexOfObject:self.pauseButton]] = self.playButton;
        [self.topToolbar setItems:items animated:NO];
    }
    [self.performanceManager pause];
}

- (void)stop
{
    [self dismissPopovers:YES];
    if ([self.performanceManager isPlaying]) {
        [self.performanceManager stop];
    }
    if (nil == self.performanceManager.startMeasure) {
        [self showEnterMeasurePrompt];
    }
    
    [self removeMeasureHighlight];
}

- (void)rewind
{
    [self dismissPopovers:YES];
    
    if (PerformanceModeAdvancedScroll == self.performanceMode) {       
        Measure *startMeasure = [self.performanceManager startMeasure];
        if (nil != startMeasure) {
            // Stop performance, remove measure highlight and scroll to (highlighted) start measure
            [self.performanceManager stop];
            [self removeMeasureHighlight];
            CGPoint position = [self.performanceManager measurePositionOnCanvas:startMeasure];
            [self scrollToMeasureAtPoint:position
                                animated:NO
                          scrollPosition:PerformanceScrollPositionTop];
        }else {
            [self showEnterMeasurePrompt];
        }
    }else {
        if ([self.performanceManager isPlaying]) {
            [self.performanceManager pause];
            // There is no way to cancel the scrolling animation
            // This will just wait till it's over and then rewind.
            [self performSelector:@selector(rewind) withObject:nil afterDelay:.25];
            return;
        }
        
        // Switch play and pause toolbar items
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.topToolbar.items];
        if ([items containsObject:self.pauseButton]) {
            items[[items indexOfObject:self.pauseButton]] = self.playButton;
            [self.topToolbar setItems:items animated:NO];
        }
        
        
        // Scroll to top
        [self scrollToMeasureAtPoint:CGPointZero 
                            animated:NO 
                      scrollPosition:PerformanceScrollPositionTop];
    }
}

- (void)finishedPlayback
{
    // Switch play and pause toolbar items
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.topToolbar.items];
    if ([items containsObject:self.pauseButton]) {
        items[[items indexOfObject:self.pauseButton]] = self.playButton;
        [self.topToolbar setItems:items animated:NO];
    }
    
    [self showToolbars];
    [self highlightStartMeasure];
    [self removeMeasureHighlight];
    
    
    // Show finished performance view
    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kFinishedPerformanceViewWidth, kFinishedPerformanceViewHeight)];
    indicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    //indicatorView.layer.borderWidth = 2.0;
    //indicatorView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.9].CGColor;
    indicatorView.layer.cornerRadius = 8.0;
    indicatorView.layer.shadowOffset = CGSizeMake(2, 2);
    indicatorView.layer.shadowRadius = 8.0;
    indicatorView.center = self.view.center;
    indicatorView.frame = CGRectMake(roundf(indicatorView.frameX),
                                     roundf(indicatorView.frameY),
                                     indicatorView.frameWidth,
                                     indicatorView.frameHeight); // Round to avoid fuzzy drawing
    UILabel *finishedLabel = [[UILabel alloc] initWithFrame:CGRectMake(
            5,
            5,
            kFinishedPerformanceViewWidth - 10,
            kFinishedPerformanceViewHeight - 10
    )];
    finishedLabel.backgroundColor = [UIColor clearColor];
    finishedLabel.textColor = [UIColor whiteColor];
    finishedLabel.textAlignment = NSTextAlignmentCenter;
    finishedLabel.numberOfLines = 0;
    finishedLabel.font = [UIFont boldSystemFontOfSize:17.0];
    finishedLabel.adjustsFontSizeToFitWidth = YES;
    finishedLabel.minimumScaleFactor = .5;
    finishedLabel.text = MyLocalizedString(@"finishedPerformance", nil);
    
    [indicatorView addSubview:finishedLabel];
    [self.view addSubview:indicatorView];
    
    [UIView animateWithDuration:2.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         indicatorView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [indicatorView removeFromSuperview];
                     }];

}

- (void)finishedSimplePlayback
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.topToolbar.items];
    if ([items containsObject:self.pauseButton]) {
        items[[items indexOfObject:self.pauseButton]] = self.playButton;
        [self.topToolbar setItems:items animated:NO];
    }
}

#pragma mark - Scrolling and Current Measure Highlight

- (void)scrollToPoint:(CGPoint)point
{
    // Adjust point to scroll view coordinates
    point = CGPointMake(
            roundf(point.x * self.performanceScrollView.zoomScale),
            roundf(point.y * self.performanceScrollView.zoomScale)
    );
    
    // Always scroll forward
    point.y = MAX(point.y, self.performanceScrollView.contentOffset.y);
    [self.performanceScrollView setContentOffset:point animated:YES];
}

- (void)scrollToMeasureAtPoint:(CGPoint)point 
                      animated:(BOOL)animated
                scrollPosition:(PerformanceScrollPosition)scrollPosition
{
    // Adjust point to current zoom scale
    point = CGPointMake(
            roundf(point.x * self.performanceScrollView.zoomScale),
            roundf(point.y * self.performanceScrollView.zoomScale)
    );
    
    CGRect targetRect = [self targetZoneRectForScrollPosition:scrollPosition];
    if (!CGRectContainsPoint(targetRect, point)) {

        CGFloat maxX = self.performanceScrollView.contentSize.width - self.performanceScrollView.bounds.size.width;
        CGFloat maxY = self.performanceScrollView.contentSize.height - self.performanceScrollView.bounds.size.height;
        
        CGPoint offset;
        offset.x = roundf(point.x - self.performanceScrollView.bounds.size.width / 2.0f); // Scroll measure to horizontal midline
        offset.x = MAX(0, offset.x);
        offset.x = MIN(offset.x, maxX);

        offset.y = roundf(point.y - (targetRect.size.height / 2.0f) - (targetRect.origin.y - self.performanceScrollView.bounds.origin.y));
        offset.y = MAX(0, offset.y);
        offset.y = MIN(offset.y, maxY);


        [self.performanceScrollView setContentOffset:offset 
                                            animated:animated];
    }
}

- (CGRect)targetZoneRectForScrollPosition:(PerformanceScrollPosition)scrollPosition
{
    CGRect targetZone = self.performanceScrollView.bounds;
    targetZone.size.height = roundf((targetZone.size.height -  2 * kMinMeasureDistanceToEdge) / 3.0f);
    targetZone.size.width = targetZone.size.width - 2 * kMinMeasureDistanceToEdge;
    targetZone.origin.x += kMinMeasureDistanceToEdge;
    switch (scrollPosition) {
        case PerformanceScrollPositionTop:
            targetZone.origin.y += kMinMeasureDistanceToEdge;
            break;
        case PerformanceScrollPositionMiddle:
            targetZone.origin.y += kMinMeasureDistanceToEdge + targetZone.size.height;
            break;
        case PerformanceScrollPositionBottom:
            targetZone.origin.y += kMinMeasureDistanceToEdge + targetZone.size.height * 2;
            break;
        default:
            targetZone = CGRectZero;
            break;
    }
    
    return CGRectMake(
            roundf(targetZone.origin.x),
            roundf(targetZone.origin.y),
            roundf(targetZone.size.width),
            roundf(targetZone.size.height)
    );
}

#pragma mark - Measure Highlights

- (void)highlightMeasureAtPoint:(CGPoint)point
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingRollByMeasureShowArrow]) {
        [self.activeMeasureIndicator removeFromSuperview];
        self.activeMeasureIndicator.center = point;
        self.activeMeasureIndicator.frame = CGRectMake(
                roundf(self.activeMeasureIndicator.frameX * self.performanceScrollView.zoomScale),
                roundf(self.activeMeasureIndicator.frameY * self.performanceScrollView.zoomScale),
                self.activeMeasureIndicator.frameWidth,
                self.activeMeasureIndicator.frameHeight
        );
        [self.performanceScrollView addSubview:self.activeMeasureIndicator];
    }
}

- (void)removeMeasureHighlight
{
    [self.activeMeasureIndicator removeFromSuperview];
}

- (void)placeCurrentMeasureHighlight
{
    Measure *activeMeasure = self.performanceManager.activeMeasure;
    if (nil != activeMeasure) {
        CGPoint position = [self.performanceManager measurePositionOnCanvas:activeMeasure];
        [self highlightMeasureAtPoint:position];
    }else {
        [self removeMeasureHighlight];
    }
}

- (void)highlightStartMeasure
{
    Measure *startMeasure = [self.performanceManager startMeasure];
    if (nil != startMeasure && PerformanceModeAdvancedScroll == self.performanceMode) {
        CGPoint position = [self.performanceManager measurePositionOnCanvas:startMeasure];
        [self.startMeasureIndicator removeFromSuperview];
        self.startMeasureIndicator.center = position;
        self.startMeasureIndicator.frame = CGRectMake(
                roundf(self.startMeasureIndicator.frameX * self.performanceScrollView.zoomScale),
                roundf(self.startMeasureIndicator.frameY * self.performanceScrollView.zoomScale),
                self.startMeasureIndicator.frameWidth,
                self.startMeasureIndicator.frameHeight
        );
        [self.performanceScrollView addSubview:self.startMeasureIndicator];
    }else {
        [self.startMeasureIndicator removeFromSuperview];
    }
}

- (void)showVisualClick
{
    self.visualMetronomeView.alpha = 1;
    [self.view bringSubviewToFront:self.visualMetronomeView];
    [UIView animateWithDuration:.15
                     animations:^{
                         self.visualMetronomeView.alpha = 0;
                     }];
}

#pragma mark - Observe Editor presentation/dismissal

- (void)observeWillPresentEditor
{
    [self dismissPopovers:NO];

    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        [self.performanceManager stop];
        [self removeMeasureHighlight];
    }else {
        [self pause];  // toggles bar button and sends pause to performance manager
    }
    self.performanceManager.timeline = nil;
}

- (void)observeEditorDismissalWithChanges
{
    // Let's go ahead and create the timeline because the editor made changes to the context
    // The timeline gets dumped every time the editor is presented 

    [self.performanceManager createTimelineWithScrollPositions:YES];
    
    @try {
        if(self.performanceManager.startMeasure.bpm) {
            ; // Access a property.  Should fire an exception if it's been deleted
        }
        
        if ([self.performanceManager.startMeasure isDeleted] || 
            [self.performanceManager.startMeasure managedObjectContext] == nil) 
        {
            self.performanceManager.startMeasure = nil;
        }
    }
    @catch (NSException *exception) {
        self.performanceManager.startMeasure = nil;
        if (APP_DEBUG) {
            NSLog(@"Start measure has been deleted, verified through exception: %@ %s %d",
                    [exception reason], __FUNCTION__, __LINE__);
        }
    }
        
    if (nil == self.performanceManager.startMeasure) {
        if ([self.performanceManager.timeline count] > 0) {
            self.performanceManager.startMeasure = self.performanceManager.timeline[0];
        } // show enter measure prompt will be shown in view will appear
    }  
    
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        [self highlightStartMeasure];    
    }
}

#pragma mark - Observe Score Changes

- (void)observePerformanceControllerWillPresentScorePicker
{
    [self dismissPopovers:NO];

    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        [self.performanceManager stop];
        [self removeMeasureHighlight];
    }else {
        [self pause];
    }
}

- (void)observePerformanceControllerDidChangeScore
{
    self.performanceManager = [[PerformanceManager alloc] initWithScore:self.score
                                                                delegate:self
                                                         performanceMode:self.performanceMode
                                                 playtimeCalculationOnly:NO];
    [self.performanceManager createTimelineWithScrollPositions:YES];
    if ([self.performanceManager.timeline count] > 0) {
        self.performanceManager.startMeasure = self.performanceManager.timeline[0];
    }else {
        [self showEnterMeasurePrompt];
    }
    [self highlightStartMeasure]; // removes highlight if start measure is nil
    
    self.tempoToolbarView.bpmLabel.text = [NSString stringWithFormat:kMetronomeFormatString, [self.score.metronomeBpm intValue]];
    self.tempoToolbarView.noteValueImageView.image = [Helpers noteValueImageForNoteValueString:self.score.metronomeNoteValue
                                                                                imageSpecifier:NoteValueImageSpecifierPetrol];
    if (nil != self.scrollSpeedSelectorViewController) {
        self.scrollSpeedSelectorViewController.score = self.score;  // Sets label and _scrollSpeed
    }
}


#pragma mark - Observe Help show/dismiss

- (void)observePerformanceControllerWillPresentHelpView
{
    [self dismissPopovers:YES];
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        [self.performanceManager stop];
        [self removeMeasureHighlight];
    }else {
        [self pause]; // toggles bar button and sends pause to performance manager
    }
}

#pragma mark - Observe application going into background or quitting

- (void)observeApplicationWillResignActive
{
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        [self stop];
    }else {
        [self pause]; // toggles bar button and sends pause to performance manager
    }
}

#pragma mark - AirTurn notifications

- (void)observeAirTurnUpArrow:(NSNotification *)sender
{
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        if (nil != self.tempoSelectPresentationController) {
            self.tempoSelectPresentationController.delegate = nil;
            self.tempoSelectPresentationController = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if ([self.score.metronomeBpm intValue] - 1 > 0) {
            self.score.metronomeBpm = @([self.score.metronomeBpm intValue] - 1);
            [self updateBpmDisplay];

            if (nil != self.performanceManager && [self.performanceManager isPlaying]) {
                [self.performanceManager airTurnEvent];
            }
        }
    }else {
        if (nil != self.scrollSpeedSelectorViewController) {
            [self.scrollSpeedSelectorViewController downTapped];
        }
    }
}

- (void)observeAirTurnDownArrow:(NSNotification *)sender
{
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        if (nil != self.tempoSelectPresentationController) {
            self.tempoSelectPresentationController.delegate = nil;
            self.tempoSelectPresentationController = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if ([self.score.metronomeBpm intValue] + 1 <= 208) {
            self.score.metronomeBpm = @([self.score.metronomeBpm intValue] + 1);
            [self updateBpmDisplay];
            if (nil != self.performanceManager && [self.performanceManager isPlaying]) {
                [self.performanceManager airTurnEvent];
            }
        }
    }else {
        if (nil != self.scrollSpeedSelectorViewController) {
            [self.scrollSpeedSelectorViewController upTapped];
        }
    }
}

- (void)updateBpmDisplay
{
    if (nil != self.tempoToolbarView) {
        self.tempoToolbarView.bpmLabel.text = [NSString stringWithFormat:kMetronomeFormatString,
                                                        [self.score.metronomeBpm intValue]];
    }
    if (self.topToolbar.hidden) {
        if (nil == self.airTurnBpmView) {
            [[NSBundle mainBundle] loadNibNamed:@"AirTurnBpmView" owner:self options:nil];
            self.airTurnBpmView.frameX = 38;
            self.airTurnBpmView.frameY = 27;
        }else {
            [self.airTurnBpmView.layer removeAllAnimations];
        }
        self.airTurnBpmView.bpmLabel.text = [NSString stringWithFormat:kMetronomeFormatString, [self.score.metronomeBpm intValue]];
        self.airTurnBpmView.noteValueImageView.image = [Helpers noteValueImageForNoteValueString:self.score.metronomeNoteValue
                                                                                  imageSpecifier:NoteValueImageSpecifierWhite];
        
        [self.view addSubview:self.airTurnBpmView];
        self.airTurnBpmView.alpha = 1;
        [UIView animateWithDuration:2
                         animations:^{
                             self.airTurnBpmView.alpha = 0;
                         }];
    }
}

#pragma mark - Settings View Controller

- (void)showSettingsViewController:(id)sender
{
    [self dismissPopovers:NO];

    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        [self.performanceManager stop];
        [self removeMeasureHighlight];
    }else {
        [self pause];
    }
    
    [super showSettingsViewController:sender];
}

- (void)observeLanguageDidChangNotification:(NSNotification *)theNotification
{
    [super observeLanguageDidChangNotification:theNotification];
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        self.chooseStartMeasureItem.title = MyLocalizedString(@"buttonChooseStartMeasure", nil);
    }else {
        if (nil != self.scrollSpeedSelectorViewController) {
            self.scrollSpeedSelectorViewController.speedLabel.text = MyLocalizedString(@"simpleScrollSpeedSelectorSpeedLabel", nil);
        }
    }
}

#pragma mark - Gesture recognizers

- (void)observeStartMeasureLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        if (![self.performanceManager isPlaying] && nil != self.performanceManager.timeline) {
            // Adjust the touch point to page coordinates
            CGPoint touch = [recognizer locationInView:self.performanceScrollView];
            CGFloat scaleFactor = self.performanceScrollView.maximumZoomScale / self.performanceScrollView.zoomScale;
            touch.x = roundf(scaleFactor * touch.x);
            touch.y = roundf(scaleFactor * touch.y);
            float diff = FLT_MAX;
            Measure *match = nil;
            for (Measure *m in self.performanceManager.timeline) {
                CGPoint mLocation = [self.performanceManager measurePositionOnCanvas:m];
                float delta = sqrtf(powf(touch.x - mLocation.x, 2) + powf(touch.y - mLocation.y, 2));
                if (delta < diff) {
                    diff = delta;
                    match = m;
                }
            }
            if (nil != match) {
                self.performanceManager.startMeasure = match;
                [self highlightStartMeasure];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isEqual:self.startMeasureRecognizer]) {
        if (nil != self.helpViewController) {
            return NO;
        }
    }else {
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return YES;
}

#pragma mark - Utilities

- (NSMutableArray *)topToolbarItems
{
    NSMutableArray *items; 
    
    if (self.performanceMode == PerformanceModeAdvancedScroll) {
        items = [@[
                self.backItem,
                self.tempoItem,
                self.chooseStartMeasureItem,
                [Helpers flexibleSpaceItem],
                self.rewindButton,
                [Helpers fixedSpaceItem:10],
                self.stopItem,
                [Helpers fixedSpaceItem:10],
                self.playButton,
                [Helpers flexibleSpaceItem],
                self.performanceModePickerItem,
                self.helpItem] mutableCopy];
    } else {
        items = [@[
                self.backItem,
                [Helpers flexibleSpaceItem],
                self.rewindButton,
                [Helpers fixedSpaceItem:10],
                [self.performanceManager isPlaying] ? self.pauseButton : self.playButton,
                [Helpers flexibleSpaceItem],
                self.performanceModePickerItem,
                self.helpItem] mutableCopy];
    }
    
    if (nil == self.setList) {
        [items removeObject:self.scorePickerItem];
    }
    
    return items;
}

- (NSMutableArray *)bottomToolbarItems
{
    NSMutableArray *bottomToolbarItems = [@[
            self.measureEditorItem,
            [Helpers flexibleSpaceItem],
            self.annotationEditorItem,
            [Helpers flexibleSpaceItem],
            self.settingsItem,
            [Helpers flexibleSpaceItem],
            self.scorePickerItem,
            [Helpers flexibleSpaceItem],
            self.pagePickerItem] mutableCopy];
    if (nil == self.setList) {
        [bottomToolbarItems removeObject:self.scorePickerItem];
    }
    return bottomToolbarItems;
}

- (NSMutableArray *)helpItems
{
    NSMutableArray *items = nil;
    
    if (self.performanceMode == PerformanceModeAdvancedScroll) {
        items = [@[
                [(TempoToolbarView *) self.tempoItem.customView actionButton],
                self.chooseStartMeasureItem,
                self.rewindButton,
                self.stopItem,
                self.playButton] mutableCopy];
    } else {
        items = [@[
                self.rewindButton,
                self.playButton] mutableCopy];
    }
    
    [items addObjectsFromArray:@[self.modePickerView.theButton,
                                 self.measureEditorItem,
                                 self.annotationEditorItem,
                                 self.settingsItem,
                                 self.scorePickerItem,
                                 self.pagePickerItem]];
    
    if (nil == self.setList) {
        [items removeObject:self.scorePickerItem];
    }
    return items;
    
}

- (NSArray *)helpTemplates
{
    NSString *scorePicker = MyLocalizedString(@"barHelpTemplateScorePicker", nil);
    NSMutableArray *templates = [NSMutableArray array];
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        [templates addObjectsFromArray:@[
                                         MyLocalizedString(@"barHelpTemplateTempoPicker", nil),
                                         MyLocalizedString(@"barHelpTemplateStartMeasure", nil),
                                         MyLocalizedString(@"barHelpTemplateAdvancedRewind", nil),
                                         MyLocalizedString(@"barHelpTemplateStop", nil),
                                         MyLocalizedString(@"barHelpTemplateAdvancedPlay", nil),
                                         ]];
    }else {
        [templates addObjectsFromArray:@[
                                         MyLocalizedString(@"barHelpTemplateSimpleRewind", nil),
                                         MyLocalizedString(@"barHelpTemplateSimplePlay", nil),
                                         ]];
    }
    [templates addObjectsFromArray:@[
                                     MyLocalizedString(@"barHelpTemplateModePicker", nil),
                                     MyLocalizedString(@"barHelpTemplateMeasureEditor", nil),
                                     MyLocalizedString(@"barHelpTemplateAnnotationEditor", nil),
                                     MyLocalizedString(@"barHelpTemplateSettings", nil),
                                     scorePicker,
                                     MyLocalizedString(@"barHelpTemplatePagePicker", nil)
                                     ]];
    if (nil == self.setList) {
        [templates removeObject:scorePicker];
    }
    return templates;

}

- (NSString *)mainHelpTemplate
{
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        return MyLocalizedString(@"mainAdvancedScrollHelpTemplate", nil);
    }else {
        return MyLocalizedString(@"mainSimpleScrollHelpTemplate", nil);
    }
}

- (void)dismissPagePicker
{
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
    }
}

- (NSString *)sleepIdentifier
{
    return @"PerformanceScrollingViewController";
}

- (void)removeCountInView
{
    [self.countInView removeFromSuperview];
    self.countInView = nil;
}

#pragma mark - Popovers

- (void)showEnterMeasurePrompt
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kShowHelpers]) {
        if (PerformanceModeAdvancedScroll == self.performanceMode && nil == self.enterMeasurePresentationController) {
            HelpViewPopOverViewController *controller = [[HelpViewPopOverViewController alloc] initWithTemplate:MyLocalizedString(@"barHelpTemplateEnterMeasurePrompt", nil)
                                                                                                       controlItem:nil
                                                                                               webViewFinishedLoad:nil];
            controller.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
            self.enterMeasurePresentationController = controller.popoverPresentationController;
            self.enterMeasurePresentationController.delegate = self;
            self.enterMeasurePresentationController.barButtonItem = self.measureEditorItem;
            self.enterMeasurePresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            self.enterMeasurePresentationController.passthroughViews = nil;
            [controller loadContent];
        }
    }
}


// Only called in response to user interaction
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if ([popoverPresentationController isEqual:self.tempoSelectPresentationController]) {
        self.tempoSelectPresentationController.delegate = nil;
        self.tempoSelectPresentationController = nil;
    }else if ([popoverPresentationController isEqual:self.enterMeasurePresentationController]) {
        self.enterMeasurePresentationController.delegate = nil;
        self.enterMeasurePresentationController = nil;
    }
}

- (void)dismissPopovers:(BOOL)animated
{
    if (nil != self.tempoSelectPresentationController) {
        self.tempoSelectPresentationController.delegate = nil;
        self.tempoSelectPresentationController = nil;
    }
    if (nil != self.enterMeasurePresentationController) {
        self.enterMeasurePresentationController.delegate = nil;
        self.enterMeasurePresentationController = nil;
    }

    [super dismissPopovers:animated]; // calls dismiss view controller
}

#pragma mark - Memory Management

- (void)dismissSelf
{
    [self dismissPopovers:NO];
    
    [self.performanceManager stop];
    self.performanceManager = nil;
    
    // has to come last
    [super dismissSelf];
}

- (void)dealloc
{
    [self shutdown];
    if (nil != self.performanceManager) {
        [self.performanceManager stop];
    }
}

@end
