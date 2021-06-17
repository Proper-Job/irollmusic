    //
//  PerformancePageViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "PerformancePagingViewController.h"
#import "Score.h"
#import "Page.h"
#import "ZoomingScrollView.h"
#import "ImageTilingView.h"
#import "PerformanceAnnotationView.h"
#import "PageNumberIndicatorView.h"
#import "ModePickerView.h"
#import "MetricsManager.h"

@implementation PerformancePagingViewController

- (id)initWithSet:(Set *)theSet
            score:(Score *)theScore
             page:(Page *)thePage
{
	if ((self = [super initWithSet:theSet 
                             score:theScore 
                              page:thePage 
                  presentingObject:nil
                   dismissSelector:NULL
                   performanceMode:PerformanceModePage])) 
    {
        ;
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad]; // check super for important initializations
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.nextPageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(nextPage)];
    
    self.previousPageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"previous"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(previousPage)];
    
    [self.topToolbar setItems:[self topToolbarItems]];
    [self.bottomToolbar setItems:[self bottomToolbarItems]];
    
    ///////////////////////////////
    // Tap zone gesture recognizer 
    ///////////////////////////////
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZoneTapped:)];
	tapGesture.cancelsTouchesInView = NO; 
	tapGesture.delaysTouchesEnded = NO;
	tapGesture.numberOfTouchesRequired = 1; // One finger
	tapGesture.numberOfTapsRequired = 1; //  Single tap
	[self.performanceScrollView addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reconfigurePages];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setupCanvas];
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

    self.canvasDidSetup = NO;

    self.performanceScrollView.contentSize = CGSizeMake(
            [self.score.pages count] * size.width,
            size.height
    );
    self.performanceScrollView.contentOffset = CGPointMake(
            size.width * self.activePageIndex,
            0
    );
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        [self reconfigurePages];
        [self.view setNeedsLayout];
    } completion:nil];
}

#pragma mark -  Metrics

- (void)setupCanvas
{
    CGRect contentFrame = [self contentFrame];
    self.performanceScrollView.contentSize = CGSizeMake(
            [self.score.pages count] * contentFrame.size.width,
            contentFrame.size.height
    );
    self.canvasDidSetup = YES;
    [self drawPages];
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
    CGRect pageFrame = [self contentFrame];
    pageFrame.origin.x = pageFrame.size.width * index;
    return pageFrame;
}

- (CGRect)contentFrame
{
    return self.view.bounds;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self drawPages];
}

#pragma mark - Page Display

- (void)drawPages
{
    if (!self.canvasDidSetup) {
        return;
    }

    // Calculate which pages are visible
    CGRect visibleBounds = self.performanceScrollView.bounds;
    NSUInteger firstNeededPageIndex = (NSUInteger) floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSUInteger lastNeededPageIndex = (NSUInteger) floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex = MIN(lastNeededPageIndex, [self.score.pages count] - 1);
    //NSLog(@"first page: %d last page: %d", firstNeededPageIndex, lastNeededPageIndex);

    CGFloat pageWidth = self.performanceScrollView.frameWidth;

    NSUInteger pageIndex = (NSUInteger) (floorf((self.performanceScrollView.contentOffset.x - (pageWidth / 2)) / pageWidth) + 1);
    //NSLog(@"page index: %lu", (unsigned long) pageIndex);
    if (pageIndex != self.activePageIndex && pageIndex < [[self orderedPagesAsc] count]) {
        self.activePageIndex = pageIndex;
        self.activePage = [self orderedPagesAsc][pageIndex];
        if (nil != self.pagePickerScrollView) {
            self.pagePickerScrollView.activePage = self.activePage;
            [self.pagePickerScrollView viewControllerPageSelectionDidChange];
        }
        self.pagePickerItem.title = [NSString stringWithFormat:MyLocalizedString(@"currentPageIndicator", nil),
                                                               self.activePageIndex + 1, [self.score.pages count]];
    }

    // Recycle no-longer-visible pages
    for (ZoomingScrollView *zoomingScrollView in self.visiblePages) {
        if (zoomingScrollView.index < firstNeededPageIndex || zoomingScrollView.index > lastNeededPageIndex) {
            [self.recycledPages addObject:zoomingScrollView];
            [zoomingScrollView removeFromSuperview];
            [zoomingScrollView invalidate];
        }
    }
    [self.visiblePages minusSet:self.recycledPages];
    if (kAvoidRecyclingPagingPerformance) {
        [self.recycledPages removeAllObjects];
    }
	
	// add missing pages
    for (NSUInteger index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ZoomingScrollView *zoomingScrollView;
            if(kAvoidRecyclingPagingPerformance) {
                zoomingScrollView = nil;
            }else {
                zoomingScrollView = [self dequeueRecycledPage];
            }
            if (nil == zoomingScrollView) {
                zoomingScrollView = [[ZoomingScrollView alloc] init];
            }
			[self configurePage:zoomingScrollView 
                       forIndex:index];
            [zoomingScrollView willDisplay];
            [self.performanceScrollView addSubview:zoomingScrollView];
            [self.visiblePages addObject:zoomingScrollView];
        }
    }
}

- (void)configurePage:(ZoomingScrollView *)zoomingScrollView 
			 forIndex:(NSUInteger)index
{
    Page *page = [self orderedPagesAsc][index];
    zoomingScrollView.index = index;
    zoomingScrollView.tilingView.index = index;
	zoomingScrollView.page = page;
    zoomingScrollView.tilingView.page = page;
    zoomingScrollView.tilingView.annotationView.page = page;
    zoomingScrollView.frame = [self frameForPageAtIndex:index];

    CGRect displayRect = CGRectMake(0, 0, [page width], [page height]);
    zoomingScrollView.contentSize = displayRect.size;
    zoomingScrollView.backgroundImageView.frame = displayRect;
    zoomingScrollView.tilingView.frame = displayRect;
    zoomingScrollView.tilingView.annotationView.frame = displayRect;
    zoomingScrollView.minimumZoomScale = [self contentFrame].size.width / [MetricsManager scoreWidthAtFullScale];;
    zoomingScrollView.maximumZoomScale = 1.0;
    zoomingScrollView.zoomScale = zoomingScrollView.minimumZoomScale;
}

- (void)reconfigurePages
{
    for (ZoomingScrollView *page in self.visiblePages) {
        page.zoomScale = 1.0;
        [self configurePage:page
                   forIndex:page.index];
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
	for (ZoomingScrollView *page in self.visiblePages) {
		if (page.index == index) {
			return YES;
		}
	}
	return NO;
}

- (ZoomingScrollView *)dequeueRecycledPage
{
    ZoomingScrollView *page = [self.recycledPages anyObject];
    if (nil != page) {
        [self.recycledPages removeObject:page];
    }
    return page;
}

- (void)refreshAnnotations
{
    [super refreshAnnotations];
    for(ZoomingScrollView *page in self.visiblePages) {
        [page willDisplay];
    }
}

#pragma mark - Tap Zones

- (void)showPage:(Page *)thePage animated:(BOOL)animated
{
    CGRect newRect = [self contentFrame];
    newRect.origin.x = newRect.size.width * ([thePage.number intValue] -1);
    [self.performanceScrollView scrollRectToVisible:newRect animated:animated];
}

- (IBAction)previousPage
{
    [self previousPageAnimated:YES];
}

- (void)previousPageAnimated:(BOOL)animated
{
    if (self.activePageIndex > 0) {
        Page *newPage = [self orderedPagesAsc][self.activePageIndex - 1];
        [self showPage:newPage animated:animated];            
    }
}

- (IBAction)nextPage
{
    [self nextPageAnimated:YES];
}

- (void)nextPageAnimated:(BOOL)animated
{
    if (self.activePageIndex < [self.score.pages count] -1) {
        Page *newPage = [self orderedPagesAsc][self.activePageIndex + 1];
        [self showPage:newPage animated:animated];            
    }
}

- (void)tapZoneTapped:(UIGestureRecognizer *)recognizer
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingEnablePagingTapZones]) {
        [self handleTapOrPedal:[recognizer locationInView:self.view]];
    }else {
        return;
    }
}

- (void)handleTapOrPedal:(CGPoint)touch
{
    if (self.performanceScrollView.dragging || self.performanceScrollView.decelerating) {
        return;
    }
    
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
        return;
    }
    
    BOOL showPageNumber = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingPagingTapZoneFlashPageNumber];
    
    CGFloat offsetRequiringScrolling;
    if (self.view.frameHeight > self.view.frameWidth) {
        offsetRequiringScrolling = kOffsetRequiringScrollingPortrait;
    }else {
        offsetRequiringScrolling = kOffsetRequiringScrollingLandscape;
    }
    CGSize boundsSize = self.view.bounds.size;
    CGRect previousRect = CGRectMake(0, 0, boundsSize.width / 2.0f, boundsSize.height);
    CGRect nextRect = CGRectMake(boundsSize.width / 2.0f, 0, boundsSize.width / 2.0f, boundsSize.height);
//    CGPoint touch = [recognizer locationInView:self.view];
    ZoomingScrollView *zoomingScrollView = [self.visiblePages anyObject];
    
    if (CGRectContainsPoint(previousRect, touch)) {
        CGFloat distanceToTop = zoomingScrollView.contentOffset.y;
        if (distanceToTop > offsetRequiringScrolling) {
            CGFloat scrollToY = MAX(zoomingScrollView.contentOffset.y - boundsSize.height, 0);
            [zoomingScrollView setContentOffset:CGPointMake(zoomingScrollView.contentOffset.x, scrollToY)
                                       animated:YES];
            
            if (showPageNumber) {
                [self.pageNumberView showPageNumber:self.activePageIndex + 1 
                                             inView:self.view
                                     positionInView:PageNumberIndicatorPositionCenter
                                tapZonePagePosition:TapZonePagePositionTop];
            }
            
        }else if (self.activePageIndex > 0) {
            [self previousPageAnimated:NO]; // centers page on screen
            TapZonePagePosition tapZonePosition = TapZonePagePositionNone;
            
            zoomingScrollView = nil; // garbage pointer
            ZoomingScrollView *newZoomingView = [self.visiblePages anyObject];
            
            // Make the bottom of the previous page visible
            // if the new content size is much bigger than the visible area
            if (newZoomingView.contentSize.height > boundsSize.height + kEnablePagePositionThreshold) {
                tapZonePosition = TapZonePagePositionBottom;
                CGFloat scrollToY = MAX(newZoomingView.contentSize.height - boundsSize.height, 0);
                newZoomingView.contentOffset = CGPointMake(newZoomingView.contentOffset.x, scrollToY);
            }
            
            if (showPageNumber) {
                [self.pageNumberView showPageNumber:self.activePageIndex + 1 
                                             inView:self.view
                                     positionInView:PageNumberIndicatorPositionCenter
                                tapZonePagePosition:tapZonePosition];
            }
        }
    }else if (CGRectContainsPoint(nextRect, touch)) {
        CGRect visibleBounds = zoomingScrollView.bounds;
        CGFloat distanceToBottom = roundf(zoomingScrollView.contentSize.height -  CGRectGetMaxY(visibleBounds));
        
        if (distanceToBottom > offsetRequiringScrolling) {
            CGFloat maxY = zoomingScrollView.contentSize.height - visibleBounds.size.height;
            CGFloat desiredY = roundf(visibleBounds.origin.y + visibleBounds.size.height * .5f);
            CGFloat scrollToY = MIN(maxY, desiredY);

            [zoomingScrollView setContentOffset:CGPointMake(zoomingScrollView.contentOffset.x, scrollToY) 
                                       animated:YES];
            
            if (showPageNumber) {
                [self.pageNumberView showPageNumber:self.activePageIndex + 1 
                                             inView:self.view
                                     positionInView:PageNumberIndicatorPositionCenter
                                tapZonePagePosition:TapZonePagePositionBottom];
            }
            
        }else if (self.activePageIndex < [self.score.pages count] -1) {
            [self nextPageAnimated:NO]; // centers page on screen
            TapZonePagePosition tapZonePosition = TapZonePagePositionNone;
            
            zoomingScrollView = nil; // garbage pointer
            ZoomingScrollView *newZoomingView = [self.visiblePages anyObject];
            
            
            // The top of the content area is shown by default, we don't need to do anything to make that happen
            // Show the tap zone arrow direction only if the content area is much larger than the visible area
            if (newZoomingView.contentSize.height > boundsSize.height + kEnablePagePositionThreshold) {
                tapZonePosition = TapZonePagePositionTop;
            }
            
            if (showPageNumber) {
                [self.pageNumberView showPageNumber:self.activePageIndex + 1 
                                             inView:self.view
                                     positionInView:PageNumberIndicatorPositionCenter
                                tapZonePagePosition:tapZonePosition];
            }
        }
    }
}

#pragma mark - Utilities

- (NSMutableArray *)topToolbarItems
{
    NSMutableArray *items = [@[
            self.backItem,
            [Helpers flexibleSpaceItem],
            self.performanceModePickerItem,
            self.helpItem

    ] mutableCopy];
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
            self.previousPageItem,
            self.pagePickerItem,
            self.nextPageItem] mutableCopy];
    if (nil == self.setList) {
        [bottomToolbarItems removeObject:self.scorePickerItem];
    }
    return bottomToolbarItems;
}

- (NSMutableArray *)helpItems
{
    NSMutableArray *items = [@[
            self.modePickerView.theButton,
            self.measureEditorItem,
            self.annotationEditorItem,
            self.settingsItem,
            self.scorePickerItem,
            self.previousPageItem,
            self.pagePickerItem,
            self.nextPageItem] mutableCopy];
    
    if (nil == self.setList) {
        [items removeObject:self.scorePickerItem];
    }
    return items;
}


- (NSArray *)helpTemplates
{
    NSString *scorePicker = MyLocalizedString(@"barHelpTemplateScorePicker", nil);
    NSMutableArray *templates = [NSMutableArray arrayWithArray:@[
            MyLocalizedString(@"barHelpTemplateModePicker", nil),
            MyLocalizedString(@"barHelpTemplateMeasureEditor", nil),
            MyLocalizedString(@"barHelpTemplateAnnotationEditor", nil),
            MyLocalizedString(@"barHelpTemplateSettings", nil),
            scorePicker,
            MyLocalizedString(@"barHelpTemplatePreviousPage", nil),
            MyLocalizedString(@"barHelpTemplatePagePicker", nil),
            MyLocalizedString(@"barHelpTemplateNextPage", nil)
    ]];
    
    if (nil == self.setList) {
        [templates removeObject:scorePicker];
    }
    return templates;
}

- (NSString *)mainHelpTemplate
{
    return MyLocalizedString(@"mainPagingHelpTemplate", nil);
}

- (PageNumberIndicatorView *)pageNumberView
{
    if (nil == _pageNumberView) {
        [[NSBundle mainBundle] loadNibNamed:@"PageNumberIndicatorView" owner:self options:nil];
        _pageNumberView.alpha = 0;
    }
    return _pageNumberView;
}

- (NSString *)sleepIdentifier
{
    return @"PerformancePagingViewController";
}

#pragma mark - AirTurn notifications

- (void)observeAirTurnUpArrow:(NSNotification *)sender
{
    [self handleTapOrPedal:CGPointMake(1, 1)];
}

- (void)observeAirTurnDownArrow:(NSNotification *)sender
{
    [self handleTapOrPedal:CGPointMake(self.view.frameWidth - 1, self.view.frameHeight - 1)];
}

@end
