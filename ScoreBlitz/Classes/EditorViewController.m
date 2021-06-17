//
//  EditorViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 21.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "EditorViewController.h"
#import "PdfView.h"
#import "Score.h"
#import "Page.h"
#import "MeasureEditorViewController.h"
#import "Measure.h"
#import "ScoreManager.h"
#import "MeasureMarkerView.h"
#import "Repeat.h"
#import "Jump.h"
#import "MultipleMeasureEditorViewController.h"
#import "ModePickerView.h"
#import "HelpAwareSegmentedControl.h"
#import "EditorScrollView.h"
#import "TrackingManager.h"
#import "ToolbarBackButtonView.h"
#import "MetricsManager.h"

@implementation EditorViewController


- (instancetype)initWithScore:(Score *)theScore
                    page:(Page *)thePage
editorViewControllerType:(EditorViewControllerType)type
            dismissBlock:(void (^)(Measure *startMeasure))dismissBlock
{
    if ((self = [super initWithNibName:@"EditorViewController" bundle:nil])) {
        self.score = theScore;
        self.activePage = thePage != nil ? thePage : [self.score orderedPagesAsc][0];
        self.editorViewControllerType = type;
        self.dismissBlock = dismissBlock;

        Measure *lastMeasure = [[self.score measuresSortedByCoordinates] lastObject];
        if (nil != lastMeasure.timeNumerator && nil != lastMeasure.timeDenominator && nil != lastMeasure.bpm) {
            activeTimeSignature.numerator = [lastMeasure.timeNumerator intValue];
            activeTimeSignature.denominator = [lastMeasure.timeDenominator intValue];
            self.activeBpm = [lastMeasure.bpm copy];
        } else {
            activeTimeSignature.numerator = 4;
            activeTimeSignature.denominator = 4;
            self.activeBpm = [[NSNumber alloc] initWithInt:0];
        }
        [[NSNotificationCenter defaultCenter] addObserverForName:kDisableGestureRecognizersInEditor
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          self.gestureRecognizersDisabled = YES;
                                                      }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kEnableGestureRecognizersInEditor
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          self.gestureRecognizersDisabled = NO;
                                                      }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.topToolbar.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.containerScrollView.multipleTouchEnabled = YES;
    self.containerScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.modePickerView.modeLabel.text = [Helpers localizedEditorTypeStringForType:self.editorViewControllerType];

    // Setup preview image view
    self.previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.previewImageView.backgroundColor = [UIColor whiteColor];
    self.previewImageView.tag = kEditorPreviewImageViewTag;
    self.previewImageView.userInteractionEnabled = YES;
    [self.containerScrollView addSubview:self.previewImageView];

    [[NSBundle mainBundle] loadNibNamed:@"ToolbarBackButtonView" owner:self options:nil];
    EditorViewController __weak *weakSelf = self;
    self.backButtonView.backPressedBlock = ^void(UIButton *sender) {
        [weakSelf dismissSelf];
    };
    self.backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButtonView];

    self.nextPageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(nextPage)];
    
    self.previousPageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"previous"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(previousPage)];
    
    self.helpItem = [[UIBarButtonItem alloc] initWithTitle:@"?"
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(showHelpViewController)];
    
    [[NSBundle mainBundle] loadNibNamed:@"ModePickerView" owner:self options:nil];
    self.modePickerView.modeLabel.text = [Helpers localizedEditorTypeStringForType:self.editorViewControllerType];
    self.editorTypeChooserItem = [[UIBarButtonItem alloc] initWithCustomView:self.modePickerView];

    // Page picker
    NSString *pagePickerTitle = [NSString stringWithFormat:MyLocalizedString(@"currentPageIndicator", nil),
                    [self.score.orderedPagesAsc indexOfObject:self.activePage] + 1, [self.score.pages count]];
    self.pagePickerItem = [[UIBarButtonItem alloc] initWithTitle:pagePickerTitle
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(togglePagePicker)];
    ///////////////////////
    // Gesture recognizers
    ///////////////////////
    
    self.swipeSelectRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(swipeSelect:)];
    self.swipeSelectRecognizer.minimumNumberOfTouches = 2;
    self.swipeSelectRecognizer.maximumNumberOfTouches = 2;
    self.swipeSelectRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.swipeSelectRecognizer];
      
    self.pagePickerDismissRecognizer = [Helpers singleFingerTabRecognizerwithTarget:self
                                                                              action:@selector(dismissPagePickerAnimated) 
                                                                            delegate:self];
    [self.view addGestureRecognizer:self.pagePickerDismissRecognizer];

    if (EditorViewControllerTypeAnnotations == self.editorViewControllerType) {
        self.annotationsView = [[AnnotationsView alloc] initWithFrame:CGRectZero
                                                                 page:self.activePage
                                                             delegate:self];
        self.previousPageItem.target = self.annotationsView;
        self.previousPageItem.action = @selector(previousTapped);
        self.nextPageItem.target = self.annotationsView;
        self.nextPageItem.action = @selector(nextTapped);
    }

    [self.topToolbar setItems:[self topToolbarItems]
                     animated:YES];
    [self.bottomToolbar setItems:[self bottomToolbarItems]
                        animated:YES];

    [[TrackingManager sharedInstance] trackGoogleViewWithIdentifier:[Helpers
            trackingStringForEditorType:self.editorViewControllerType]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.topToolbarTopConstraint.constant = self.topLayoutGuide.length;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self showPage:self.activePage];
    [self showTopToolbarPrompt];
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    if (nil != self.markerPopOver) {
        [self.markerPopOver dismissPopoverAnimated:NO];
        self.markerPopOver = nil;
    }

    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:NO];
    }

    self.zoomEnabled = YES;
    [self.containerScrollView setZoomScale:1.0 animated:NO];
    self.zoomEnabled = NO;
    self.pdfView.layer.contents = nil;

    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
         [self.view setNeedsLayout]; // calls through to didLayoutSubview which in turns call showPage:
     }completion:nil];
}

#pragma mark - Editor Type

- (IBAction)showModePicker
{
    EditorTypeChooserTableViewController * controller = [[EditorTypeChooserTableViewController alloc] initWithEditorType:self.editorViewControllerType
                                                                                                    typePickedCompletion:^(EditorViewControllerType newType)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self.editorViewControllerType != newType) {
            EditorViewController *editor = [[EditorViewController alloc] initWithScore:self.score
                                                                                  page:self.activePage
                                                              editorViewControllerType:newType
                                                                          dismissBlock:self.dismissBlock];
            NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
            if (viewControllers.count > 0) {
                viewControllers[viewControllers.count - 1] = editor;
                [self.navigationController setViewControllers:viewControllers animated:NO];
            }
        }
    }];
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
    controller.popoverPresentationController.barButtonItem = self.editorTypeChooserItem;
    controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
}

#pragma mark - Page Display

- (void)showPage:(Page *)thePage
{
    if (![thePage isEqual:self.activePage] || nil == self.pdfView) {
        self.zoomEnabled = YES;
        [self.containerScrollView setZoomScale:1.0 animated:NO];
        self.zoomEnabled = NO;

        PdfView *newPdfView = [[PdfView alloc] initWithFrame:CGRectZero];
        [self configurePdfView:newPdfView forPage:thePage];
        [newPdfView willDisplay];
        [self.previewImageView addSubview:newPdfView];

        [self.pdfView invalidate];
        [self.pdfView removeFromSuperview];
        self.activePage = thePage;
        self.pdfView = newPdfView;

        if (EditorViewControllerTypeAnnotations == self.editorViewControllerType) {
            self.annotationsView.frame = self.pdfView.bounds;
            if (nil != self.pagePickerScrollView) {
                [self.pdfView insertSubview:self.annotationsView
                               belowSubview:self.pagePickerScrollView];
            } else {
                [self.pdfView addSubview:self.annotationsView];
            }
            [self.annotationsView activePageDidChange:self.activePage];
            if (AnnotationInputModeZoom == self.annotationsView.inputControlSegment.selectedSegmentIndex) {
                self.zoomEnabled = YES;
            }
        } else {
            [self loadMarkerViews];
        }

        if (nil != self.pagePickerScrollView) {
            self.pagePickerScrollView.activePage = thePage;
            [self.pagePickerScrollView viewControllerPageSelectionDidChange];
        }
    }else {
        // reconfigure
        [self configurePdfView:self.pdfView forPage:thePage];
        [self positionMarkerViews];
        if (nil != self.annotationsView) {
            if (AnnotationInputModeZoom == self.annotationsView.inputControlSegment.selectedSegmentIndex) {
                self.zoomEnabled = YES;
            }
            [self.annotationsView configureForFrame:self.pdfView.frame];
        }
    }
    self.containerScrollView.contentSize = [self contentAreaFrame].size;
    [self.pdfView setNeedsDisplay];
}

- (void)configurePdfView:(PdfView *)thePdfView 
				 forPage:(Page *)thePage
{
    thePdfView.multipleTouchEnabled = YES;  // Allow pdfView to forward multi touch sequences to container view
    thePdfView.tag = kPdfViewTag;
    thePdfView.score = self.score;
    thePdfView.index = [thePage.number intValue] -1;
    
    if (![self.addMarkerRecognizer.view isEqual:thePdfView]) {
        self.addMarkerRecognizer.delegate = nil;
        self.addMarkerRecognizer = [Helpers singleFingerTabRecognizerwithTarget:self
                                                                          action:@selector(addMarker:)
                                                                        delegate:self];
        [thePdfView addGestureRecognizer:self.addMarkerRecognizer];
    }
	
	CGRect contentBox = [thePage contentBox];
	CGRect contentArea = [self contentAreaFrame];
	CGFloat scale = 1.0f;
    thePdfView.contentBox = contentBox;
    
	if ([thePage isPortrait]) {
		scale = contentArea.size.height / contentBox.size.height;
		
		// If scaling to height makes the width overlap the visible bounds, size to width instead
		if (contentBox.size.width * scale > contentArea.size.width) {
			scale = contentArea.size.width / contentBox.size.width;
		}
	}else {
		scale = contentArea.size.width / contentBox.size.width;
		
		// If scaling to width makes the height overlap the visible bounds, size to height instead
		if (contentBox.size.height * scale > contentArea.size.height) {
			scale = contentArea.size.height / contentBox.size.height;
		}
	}
    
	thePdfView.scale = scale;
	CGSize pdfSize = CGSizeMake(
            roundf(contentBox.size.width * scale),
            roundf(contentBox.size.height * scale)
    );
	CGRect previewFrame = CGRectMake(
            roundf((contentArea.size.width - pdfSize.width) / 2.0f),
            roundf(((contentArea.size.height - pdfSize.height) / 2.0f)),
            pdfSize.width,
            pdfSize.height
    );

	thePdfView.frameSize = pdfSize;
    thePdfView.frameOrigin = CGPointZero;
    
	self.previewImageView.frame = previewFrame;
    self.previewImageView.image = [thePage previewImage];

    NSArray *orderedPages = self.score.orderedPagesAsc;
    self.pagePickerItem.title = [NSString stringWithFormat:MyLocalizedString(@"currentPageIndicator", nil),
                    [orderedPages indexOfObject:thePage] + 1, orderedPages.count];
    
    // calculate max zoom scale for current page
    self.containerScrollView.minimumZoomScale = 1.0;
    self.containerScrollView.maximumZoomScale = MAX(
            1.0f,
            [MetricsManager scoreWidthAtFullScale] / previewFrame.size.width
    );
}

- (CGRect)contentAreaFrame
{
    return CGRectMake(
            0,
            0,
            self.containerScrollView.bounds.size.width,
            self.containerScrollView.bounds.size.height
    );
}


- (IBAction)previousPage
{
	NSUInteger activePageIndex = [self.score.orderedPagesAsc indexOfObject:self.activePage];
	if (0 != activePageIndex) {
        [self showPage:self.score.orderedPagesAsc[activePageIndex - 1]];

	}
}

- (IBAction)nextPage
{
    NSUInteger activePageIndex = [self.score.orderedPagesAsc indexOfObject:self.activePage];
    if (activePageIndex + 1 < [self.score.pages count]) {
        [self showPage:self.score.orderedPagesAsc[activePageIndex + 1]];
	}
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    if ([bar isEqual:self.topToolbar]) {
        return UIBarPositionTopAttached;
    } else {
        return UIBarPositionBottom;
    }
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.topToolbar] || [touch.view isDescendantOfView:self.bottomToolbar]) {
        return NO;
    }
    if (nil != self.pagePickerScrollView && [touch.view isDescendantOfView:self.pagePickerScrollView]) {
        return NO;
    }
    
    if ([self.swipeSelectRecognizer isEqual:gestureRecognizer]) {
        if (nil != self.helpViewController) {
            return NO;
        }
        if (nil != self.annotationsView) {
            return NO;
        }
    }
    
    if ([self.pagePickerDismissRecognizer isEqual:gestureRecognizer]) {
        if(nil != self.pagePickerScrollView && [touch.view isDescendantOfView:self.pagePickerScrollView]) {
            return NO;
        }
        
        if (nil != self.annotationsView) {// && [touch.view isDescendantOfView:self.annotationsView]){
            return NO;
        }
        
        if (nil != self.helpViewController) {
            return NO;
        } 
    }
    
    if ([self.addMarkerRecognizer isEqual:gestureRecognizer]) {
        if (nil != self.helpViewController) {
            return NO;
        }
        if (nil != self.annotationsView) {
            return NO;
        }
    }
    
    if ([gestureRecognizer.view isKindOfClass:[MeasureMarkerView class]]) { // Edit measure recognizer
        if (nil != self.helpViewController) {
            return NO;
        }
        if (EditorViewControllerTypeStartMeasure == self.editorViewControllerType && 
            [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) 
        {
            // Disable drag markers in start measure picker mode
            return NO;
        }
    }

    return !self.gestureRecognizersDisabled;
}

#pragma mark - Page Picker

- (void)togglePagePicker
{
    if (nil == self.pagePickerScrollView) {
        self.pagePickerScrollView = [[PagePickerScrollView alloc] init];
        self.pagePickerScrollView.pickerDelegate = self;
        self.pagePickerScrollView.activePage = self.activePage;
        self.pagePickerScrollView.activeScore = self.score;
        [self.pagePickerScrollView showInView:self.view
                             belowToolbar:self.bottomToolbar
                            withAnimation:PagePickerShowAnimationFromBottom];
    }else {
        [self.pagePickerScrollView hideAnimated:YES];
    }
}

- (void)dismissPagePickerAnimated
{
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
    }
}

- (void)dismissPagePicker
{
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:NO];
    }
}

- (void)pickerScrollViewDidHide:(PagePickerScrollView *)thePickerScrollView
{
    self.pagePickerScrollView = nil;
}

- (void)pickerScrollViewSelectionDidChange:(Page *)newSelection
{
    if (![newSelection isEqual:self.activePage]) {
        if (EditorViewControllerTypeAnnotations == self.editorViewControllerType) {
            [self.annotationsView showPage:newSelection];
        }else {
            [self showPage:newSelection];
        }
    }
}


#pragma mark - Markers

- (void)addMarker:(UIGestureRecognizer *)gestureRecognizer
{
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
        return;
    }
    
    if (EditorViewControllerTypeStartMeasure == self.editorViewControllerType) {
        return;
    }
    
	CGPoint locationInView = [gestureRecognizer locationInView:self.pdfView];
	CGRect aRect = CGRectMake(roundf(locationInView.x - (kMeasureMarkerViewWidth / 2)),
                              roundf(locationInView.y - (kMeasureMarkerViewHeight / 2)),
                              kMeasureMarkerViewWidth,
                              kMeasureMarkerViewHeight);

    if (![self pdfViewContainsMeasureMarkerRect:aRect]) {
        return;
    }
    
	// Create Measure Object
	Measure *newMeasure = (Measure *) [[NSManagedObject alloc] initWithEntity:[Measure entityDescription]
											   insertIntoManagedObjectContext:[[ScoreManager sharedInstance] context_]];
    // Take last used time signature
    newMeasure.timeNumerator = @(activeTimeSignature.numerator);
    newMeasure.timeDenominator = @(activeTimeSignature.denominator);
    
    // Take last used tempo
    newMeasure.bpm = self.activeBpm;

  	// Add measure marker
	MeasureMarkerView *markerView = [self markerViewWithMeasure:newMeasure];
	[markerView addGestureRecognizer:[Helpers singleFingerTabRecognizerwithTarget:self 
                                                                           action:@selector(editMeasure:)
                                                                         delegate:self]];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(markerDragged:)];
    longPressRecognizer.delegate = self;
	[markerView addGestureRecognizer:longPressRecognizer];
	markerView.center = locationInView;
	markerView.frame = aRect;
	newMeasure.coordinate = CGPointMake(markerView.center.x / self.pdfView.frameWidth , markerView.center.y / self.pdfView.frameHeight);
	
	[self.pdfView addSubview:markerView];
	
    [self markersDropped:[NSSet setWithObject:markerView]];
    
    [self.measureMarkerViews addObject:markerView];
	[self.activePage addMeasuresObject:newMeasure];
	[[ScoreManager sharedInstance] saveTheFuckingContext];
}


- (void)markerDragged:(UIGestureRecognizer *)gestureRecognizer
{
	MeasureMarkerView *markerView = (MeasureMarkerView *)gestureRecognizer.view;
	if (UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        markerView.firstTouchPoint = [gestureRecognizer locationInView:markerView];
        
        self.dragSiblings = [[NSMutableSet alloc] init];
        CGFloat systemY =  markerView.measure.coordinate.y;
        for (MeasureMarkerView *aMarkerView in self.measureMarkerViews) {
            if (equalsf(aMarkerView.measure.coordinate.y, systemY)) {
                [self.dragSiblings addObject:aMarkerView];
            }
        }
		
		[UIView animateWithDuration:kGrowAnimationDurationSeconds 
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void){
                             for (MeasureMarkerView *dragSibling in self.dragSiblings) {
                                 dragSibling.transform = CGAffineTransformMakeScale(kMarkerPressedGrow, kMarkerPressedGrow);
                                 if ([self.dragSiblings count] > 1) {
                                     [dragSibling flash];
                                 }
                             }
						 }  
						 completion:^(BOOL finished) {
							 [UIView animateWithDuration:kShrinkAnimationDurationSeconds
                                                   delay:0
                                                 options:UIViewAnimationOptionAllowUserInteraction
											  animations:^(void){
                                                  for (MeasureMarkerView *dragSibling in self.dragSiblings) {
                                                      dragSibling.transform = CGAffineTransformMakeScale(kMarkerDraggingGrow, kMarkerDraggingGrow);
                                                  }
											  }
                                              completion:NULL];
						 }];
	}else if (UIGestureRecognizerStateChanged == gestureRecognizer.state) {
		CGPoint dragPoint = [gestureRecognizer locationInView:self.pdfView];
        CGPoint firstTouchPoint = markerView.firstTouchPoint;
        CGPoint offsetToCenter = CGPointMake(CGRectGetMidX(markerView.bounds) - firstTouchPoint.x,
                                             CGRectGetMidY(markerView.bounds) - firstTouchPoint.y);
        CGPoint newCenter = CGPointMake(dragPoint.x + offsetToCenter.x, dragPoint.y + offsetToCenter.y);
        
        CGRect dragTargetRect = CGRectMake(roundf(newCenter.x - (kMeasureMarkerViewWidth/2)),
                                    roundf(newCenter.y - (kMeasureMarkerViewHeight/2)),
                                    kMeasureMarkerViewWidth,
                                    kMeasureMarkerViewHeight); 
        
        if ([self pdfViewContainsMeasureMarkerRect:dragTargetRect]) {
            markerView.center = newCenter;
            markerView.frame = CGRectMake(roundf(markerView.frame.origin.x), roundf(markerView.frame.origin.y),
                                          markerView.frameWidth, markerView.frameHeight);
            for (MeasureMarkerView *dragSibling in self.dragSiblings) {
                dragSibling.frameY = markerView.frameY;
            }

        }
	}else if (UIGestureRecognizerStateEnded == gestureRecognizer.state) {

		[UIView animateWithDuration:kShrinkAnimationDurationSeconds
						 animations:^(void) {
                             for (MeasureMarkerView *dragSibling in self.dragSiblings) {
                                 dragSibling.transform = CGAffineTransformIdentity;
                             }
						 }
                         completion:^(BOOL finished) {
                             for (MeasureMarkerView *dragSibling in self.dragSiblings) {
                                 dragSibling.frame = CGRectMake(roundf(dragSibling.frame.origin.x),
                                                                roundf(dragSibling.frame.origin.y),
                                                                dragSibling.frameWidth,
                                                                dragSibling.frameHeight);
                                 dragSibling.measure.coordinate = CGPointMake(dragSibling.center.x / self.pdfView.frameWidth, 
                                                                             dragSibling.center.y / self.pdfView.frameHeight);
                             }
                             [self markersDropped:self.dragSiblings];
						 }];
	}
}

- (void)markersDropped:(NSSet *)markers
{
    MeasureMarkerView *droppedMarker = [markers anyObject];
    
    NSMutableSet *siblingMarkers = [self.measureMarkerViews mutableCopy];
    [siblingMarkers minusSet:markers];
    
    // Analyze existing measure and sort them into systems
    NSMutableDictionary *systems  = [[NSMutableDictionary alloc] init];
    for (MeasureMarkerView *aMarker in siblingMarkers) {
        if (fabsf(aMarker.center.y - droppedMarker.center.y) < kMeasuresConsideredSiblingsDeviation) {
            NSString *key = [NSString stringWithFormat:kSystemIdentificationFormat, aMarker.measure.coordinate.y];
            if (nil == systems[key]) {
                systems[key] = [NSMutableArray array];
            }
            [systems[key] addObject:aMarker];
        }
    }
    
    // Find the closest system
    if ([systems count] > 0) {
        MeasureMarkerView *closestSystemMarker = nil;
        
        CGFloat diff = MAXFLOAT;
        for (NSString* aKey in systems) {
            MeasureMarkerView *aSystemMarker = [systems[aKey] lastObject];
            CGFloat tmp = fabsf(aSystemMarker.center.y - droppedMarker.center.y);
            if (tmp < diff) {
                diff = tmp;
                closestSystemMarker = aSystemMarker;
            }
        }
        
        CGFloat systemY = closestSystemMarker.measure.coordinate.y;
        
        //Update model value(s) immediately, and save
        for (MeasureMarkerView *aMarkerView in markers) {
            Measure *theMeasure = aMarkerView.measure;
            theMeasure.coordinate = CGPointMake(theMeasure.coordinate.x, systemY);
        }
        [[ScoreManager sharedInstance] saveTheFuckingContext];
        
        // Snap dropped markers to closest system
        [UIView animateWithDuration:.125
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(void) {
                             for (MeasureMarkerView *markerView in markers) {
                                 markerView.frameY = closestSystemMarker.frameY;
                             }
                         }
                         completion:^(BOOL finished) {
                             [markers makeObjectsPerformSelector:@selector(flash)];
                             [systems[[NSString stringWithFormat:kSystemIdentificationFormat, systemY]] makeObjectsPerformSelector:@selector(flash)];
                         }];
    }
}


- (void)loadMarkerViews
{
    [self.measureMarkerViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.measureMarkerViews = [NSMutableSet set];
	
	for (Measure *measure in self.activePage.measures) {
		CGPoint relativeMeasurePosition = [measure coordinate];
		
		// Add measure marker
		MeasureMarkerView *markerView = [self markerViewWithMeasure:measure];
		[markerView addGestureRecognizer:[Helpers singleFingerTabRecognizerwithTarget:self 
                                                                               action:@selector(editMeasure:)
                                                                             delegate:self]];
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(markerDragged:)];
        longPressRecognizer.delegate = self;
		[markerView addGestureRecognizer:longPressRecognizer];
		
		markerView.center = CGPointMake(self.pdfView.frameWidth * relativeMeasurePosition.x, self.pdfView.frameHeight * relativeMeasurePosition.y);
		markerView.frame = CGRectMake(roundf(markerView.frame.origin.x), roundf(markerView.frame.origin.y),
									  markerView.frameWidth, markerView.frameHeight);
		
		[self.pdfView addSubview:markerView];
		[self.measureMarkerViews addObject:markerView];
	}
}

- (MeasureMarkerView *)markerViewWithMeasure:(Measure *)theMeasure
{
	[[NSBundle mainBundle] loadNibNamed:@"MeasureMarkerView" owner:self options:nil];
    self.measureMarkerView.measure = theMeasure;
	self.measureMarkerView.numerator.text = [theMeasure.timeNumerator stringValue];
	self.measureMarkerView.denominator.text = [theMeasure.timeDenominator stringValue];
    [self.measureMarkerView refreshSymbols];
    
    if ([self.activeStartMeasure isEqual:theMeasure]) {
        [self.measureMarkerView becomeStartMeasure];
    }
    
    MeasureMarkerView *aMarkerView = self.measureMarkerView;
    self.measureMarkerView = nil;
	return aMarkerView;
}


- (void)deleteMarkerView:(MeasureMarkerView *)theMarkerView
{
    [theMarkerView removeFromSuperview];
    [self.measureMarkerViews removeObject:theMarkerView];
}

- (void)deleteMarkerViewsForMeasures:(NSSet *)theMeasures
{
    NSSet *goners = [self.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure IN %@", theMeasures]];
    [goners makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.measureMarkerViews minusSet:goners];
}

- (void)positionMarkerViews
{
    for (MeasureMarkerView *markerView in self.measureMarkerViews) {
        CGPoint relativeMeasurePosition = [markerView.measure coordinate];
        markerView.center = CGPointMake(
                self.pdfView.frame.size.width * relativeMeasurePosition.x,
                self.pdfView.frame.size.height * relativeMeasurePosition.y
        );
        markerView.frameX = roundf(markerView.frameX);
        markerView.frameY = roundf(markerView.frameY);
    }
}

#pragma mark - Edit Measure(s)

- (void)editMeasure:(id)sender
{
    MeasureMarkerView *markerView = [sender isKindOfClass:[MeasureMarkerView class]] ? (MeasureMarkerView *)sender : (MeasureMarkerView *)[sender view];
    
    if (EditorViewControllerTypeStartMeasure == self.editorViewControllerType) {    
        [[self.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure == %@", self.activeStartMeasure]]
             makeObjectsPerformSelector:@selector(resignStartMeasure)];
        [markerView becomeStartMeasure];
        self.activeStartMeasure = markerView.measure;
    }else if (EditorViewControllerTypeMeasures == self.editorViewControllerType) {       
        MeasureEditorViewController *controller = [[MeasureEditorViewController alloc] initWithMeasure:markerView.measure
                                                                                                 score:self.score
                                                                                            markerView:markerView
                                                                                           optionState:[markerView.measure hasDetailedOptions] ? MeasureEditorOptionStateDetailed : self.measureOptionState
                                                                                      editorController:self];
        controller.timeSignatureDidChange = ^(AlpPhoneTimeSignature timeSignature) {
            activeTimeSignature = timeSignature;
        };
        controller.measureOptionStateDidChange = ^(MeasureEditorOptionState measureOptionState) {
            self.measureOptionState = measureOptionState;
        };
        controller.bpmDidChange = ^(NSNumber *bpm) {
            self.activeBpm = bpm;
        };
        controller.navigationItem.title = MyLocalizedString(@"editMeasure", nil);
        UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        if (nil != self.markerPopOver && [self.markerPopOver isPopoverVisible]) {
            [self.markerPopOver dismissPopoverAnimated:NO];
            self.markerPopOver.delegate = nil;
            self.markerPopOver = nil;
        }
        self.markerPopOver = [[UIPopoverController alloc] initWithContentViewController:aNavigationController];
        self.markerPopOver.delegate = self;
        [self.markerPopOver presentPopoverFromRect:CGRectMake(0, 0, markerView.bounds.size.width, markerView.bounds.size.height)
                                       inView:markerView
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
    }
}

- (void)editMeasures:(NSSet *)theMeasures
{
    MultipleMeasureEditorViewController *controller = [[MultipleMeasureEditorViewController alloc] initWithMeasures:theMeasures
                                                                                                              score:self.score
                                                                                                   editorController:self];
    controller.timeSignatureDidChange = ^(AlpPhoneTimeSignature timeSignature) {
        activeTimeSignature = timeSignature;
    };
    controller.bpmDidChange = ^(NSNumber *bpm) {
        self.activeBpm = bpm;
    };
    controller.preferredContentSize = controller.view.frameSize;
    UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.navigationItem.title = MyLocalizedString(@"editMultipleMeasure", nil);
    
    
    self.multiMeasurePopover = [[UIPopoverController alloc] initWithContentViewController:aNavigationController];
    self.multiMeasurePopover.delegate = self;
    MeasureMarkerView *theMarkerView = [[self.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure == %@", [theMeasures anyObject]]] anyObject];
    CGRect popoverRect = theMarkerView.frame;
    [self.multiMeasurePopover presentPopoverFromRect:popoverRect
                                         inView:self.pdfView
                       permittedArrowDirections:UIPopoverArrowDirectionAny
                                       animated:YES];
}

- (void)dismissMultiMarkerPopover
{
    if (nil != self.multiMeasurePopover && [self.multiMeasurePopover isPopoverVisible]) {
        [self.multiMeasurePopover dismissPopoverAnimated:YES];
        self.multiMeasurePopover = nil;
    }
}

- (void)dismissMarkerPopover
{
    if (nil != self.markerPopOver && self.markerPopOver.popoverVisible) {
        [self.markerPopOver dismissPopoverAnimated:YES];
        self.markerPopOver = nil;
	}
}

#pragma mark - Popover Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController { // Is not called in response to programatic dismissal
    if ([self.markerPopOver isEqual:popoverController]) {
        MeasureEditorViewController *controller = (MeasureEditorViewController *)[(UINavigationController*) self.markerPopOver.contentViewController topViewController];
        [controller.markerView stopGlow];

        self.markerPopOver.delegate = nil;
        self.markerPopOver = nil;
    }else if ([self.multiMeasurePopover isEqual:popoverController]) {
        MultipleMeasureEditorViewController *controller = (MultipleMeasureEditorViewController *)
                [(UINavigationController*) self.multiMeasurePopover.contentViewController topViewController];
        
        // Stop the glow
        [[self.measureMarkerViews
                filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure IN %@",
                                                       controller.measures]]makeObjectsPerformSelector:@selector(stopGlow)];
        
        self.multiMeasurePopover.delegate = nil;
        self.multiMeasurePopover = nil;
    }else if ([self.editorTypeChooserPopoverController isEqual:popoverController]) {
        self.editorTypeChooserPopoverController.delegate = nil;
        self.editorTypeChooserPopoverController = nil;
    }
}


#pragma mark - Swipe select
- (void)swipeSelect:(UIPanGestureRecognizer *)recognizer
{
	if (UIGestureRecognizerStateBegan == recognizer.state) {
        self.swipeSelectMeasures = [NSMutableSet set];
        if (2 == [recognizer numberOfTouches]) {
            [self selectMarkersWithPoint1:[recognizer locationOfTouch:0 inView:self.pdfView]
                                   point2:[recognizer locationOfTouch:1 inView:self.pdfView]];
        }
	}else if (UIGestureRecognizerStateChanged == recognizer.state) {
        if (2 == [recognizer numberOfTouches]) {
            [self selectMarkersWithPoint1:[recognizer locationOfTouch:0 inView:self.pdfView]
                                   point2:[recognizer locationOfTouch:1 inView:self.pdfView]];
        }
	}else if (UIGestureRecognizerStateCancelled == recognizer.state) {
        self.swipeSelectMeasures = nil;
    }else if (UIGestureRecognizerStateEnded == recognizer.state) 
    {
        if ([self.swipeSelectMeasures count] == 1) {
            MeasureMarkerView *markerView = [[self.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure == %@", [self.swipeSelectMeasures anyObject]]] anyObject];
            [self editMeasure:markerView];
        }else if ([self.swipeSelectMeasures count] > 1) {
            [self editMeasures:self.swipeSelectMeasures];
        }
        self.swipeSelectMeasures = nil;
    }
}

- (void)selectMarkersWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
    CGFloat rise = fabsf(point1.y - point2.y);
    CGFloat run = fabsf(point1.x - point2.x);
    CGFloat maxDelta = MAX(rise, run);
    
    CGFloat xTick, yTick;
    if (rise > run) {
        xTick = run / rise;
        yTick = 1;
    }else {
        xTick = 1;
        yTick = rise / run;
    }
    if (point1.x > point2.x) {
        xTick *= -1;
    }
    if (point1.y > point2.y) {
        yTick *= -1;
    }
    
    for (int i = 1; i <= maxDelta; i++) {
        CGPoint ptOnLine = CGPointMake(roundf(point1.x + xTick * i),
                                       roundf(point1.y + yTick * i));
        for (MeasureMarkerView *aMarkerView in self.measureMarkerViews) {
            if ([aMarkerView isKindOfClass:[MeasureMarkerView class]] && CGRectContainsPoint(aMarkerView.frame, ptOnLine)) {
                [aMarkerView glow];
                [self.swipeSelectMeasures addObject:aMarkerView.measure];
            }
        }
    }
}

#pragma mark - Zooming

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.zoomEnabled) {
        return self.previewImageView;
    }else {
        return nil;
    }
}

#pragma mark - HelpViewController

- (void)showHelpViewController
{
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
    }
    
    [self hideTopToolbarPrompt];
    
    TutorialType type = TutorialTypeAnnotationsEditor;
    switch (self.editorViewControllerType) {
        case EditorViewControllerTypeAnnotations:
            type = TutorialTypeAnnotationsEditor;
            break;
        case EditorViewControllerTypeMeasures:
            type = TutorialTypeMeasureEditor;
            break;
        case EditorViewControllerTypeStartMeasure:
            type = TutorialTypeStartMeasureEditor;
            break;
    }

    self.helpViewController = [[HelpViewController alloc] initWithControlItems:[self toolbarHelpItems]
                                                                     templates:[self helpTemplates]
                                                                  mainTemplate:[self mainHelpTemplate]
                                                                  tutorialType:type
                                                                    completion:^
    {
        [self.helpViewController willMoveToParentViewController:nil];
        [self.helpViewController.view removeFromSuperview];
        [self.view removeConstraints:self.helpViewConstraints];
        self.helpViewController = nil;
        self.helpItem.enabled = YES;

        if (EditorViewControllerTypeAnnotations == self.editorViewControllerType &&
                nil != self.annotationsView)
        {
            self.annotationsView.inputControlSegment.helpController = nil;
        }
        [self showTopToolbarPrompt];
    }];
    
    // Setting the help controller on the segmented control cause it
    // to forward all touches to the help controller while in help mode.
    if (EditorViewControllerTypeAnnotations == self.editorViewControllerType &&
        nil != self.annotationsView)
    {
        self.annotationsView.inputControlSegment.helpController = self.helpViewController;
    }

    self.helpViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.helpViewController.view.alpha = 0;

    [self addChildViewController:self.helpViewController];
    [self.helpViewController didMoveToParentViewController:self];
    [self.view addSubview:self.helpViewController.view];
    [self.view bringSubviewToFront:self.helpViewController.view];

    NSDictionary *views = @{
            @"helpView": self.helpViewController.view,
            @"topToolbar": self.topToolbar,
            @"bottomToolbar": self.bottomToolbar
    };
    self.helpViewConstraints = [[NSMutableArray alloc] init];
    [self.helpViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[helpView]|"
                                                                                          options:(NSLayoutFormatOptions) 0
                                                                                          metrics:nil
                                                                                            views:views]];
    [self.helpViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topToolbar][helpView][bottomToolbar]"
                                                                                          options:(NSLayoutFormatOptions) 0
                                                                                          metrics:nil
                                                                                            views:views]];
    [self.view addConstraints:self.helpViewConstraints];
    [UIView animateWithDuration:kHelpViewControllerFadeAnimationDuration
                     animations:^(void) {
                         self.helpViewController.view.alpha = 1;
                     }];

    self.helpItem.enabled = NO;
    
    [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:[Helpers trackingStringForEditorType:self.editorViewControllerType]
                                                            actionString:kTrackingEventButton
                                                             labelString:@"Help"
                                                             valueNumber:@0];
}

#pragma mark - Toolbar Items

- (NSArray *)topToolbarItems
{
    if (EditorViewControllerTypeMeasures == self.editorViewControllerType) {
        return @[
                self.backItem,
                [Helpers flexibleSpaceItem],
                self.editorTypeChooserItem,
                self.helpItem
        ];
    }else if (EditorViewControllerTypeStartMeasure == self.editorViewControllerType) {
        return @[
                self.backItem,
                [Helpers flexibleSpaceItem],
                self.helpItem
        ];
    }else if (EditorViewControllerTypeAnnotations == self.editorViewControllerType) {
        return @[
                self.backItem,
                [Helpers flexibleSpaceItem],
                self.annotationsView.annotationsPenButton,
                self.annotationsView.annotationsSegmentButton,
                [Helpers flexibleSpaceItem],
                self.editorTypeChooserItem,
                self.helpItem,
        ];
    }else {
        return [NSArray array];
    }
}

- (NSArray *)bottomToolbarItems
{
    NSMutableArray *items = [@[
            [Helpers flexibleSpaceItem],
            self.previousPageItem,
            self.pagePickerItem,
            self.nextPageItem] mutableCopy];
    if (EditorViewControllerTypeAnnotations == self.editorViewControllerType &&
            nil != self.annotationsView.annotationsClearButton)
    {
        [items insertObject:self.annotationsView.annotationsClearButton atIndex:0];
    }

    return items;
}


- (NSArray *)toolbarHelpItems  // Items combined from top and bottom toolbars
{
    switch (self.editorViewControllerType) {
        case EditorViewControllerTypeMeasures:
            return @[
                    [(ModePickerView *) self.editorTypeChooserItem.customView theButton],
                    self.previousPageItem,
                    [Helpers fixedSpaceItem:10],
                    self.pagePickerItem,
                    [Helpers fixedSpaceItem:10],
                    self.nextPageItem
            ];
        case EditorViewControllerTypeStartMeasure:
            return @[
                    self.previousPageItem,
                    [Helpers fixedSpaceItem:10],
                    self.pagePickerItem,
                    [Helpers fixedSpaceItem:10],
                    self.nextPageItem
            ];
        case EditorViewControllerTypeAnnotations:
            return @[
                    self.annotationsView.annotationsSegmentButton.customView,
                    self.annotationsView.annotationsPenButton,
                    self.annotationsView.annotationsClearButton,
                    [(ModePickerView *) self.editorTypeChooserItem.customView theButton],
                    self.previousPageItem,
                    [Helpers fixedSpaceItem:10],
                    self.pagePickerItem,
                    [Helpers fixedSpaceItem:10],
                    self.nextPageItem
            ];
        default:
            return [NSArray array];
    }
}

- (NSArray *)helpTemplates
{
    NSMutableArray *templates = [NSMutableArray array];
    if (EditorViewControllerTypeMeasures == self.editorViewControllerType) {
        [templates addObjectsFromArray:@[
                MyLocalizedString(@"barHelpTemplateEditorPicker", nil),
                MyLocalizedString(@"barHelpTemplatePreviousPage", nil),
                MyLocalizedString(@"barHelpTemplatePagePicker", nil),
                MyLocalizedString(@"barHelpTemplateNextPage", nil)
        ]];
    }else if (EditorViewControllerTypeStartMeasure == self.editorViewControllerType)  {
        [templates addObjectsFromArray:@[
                MyLocalizedString(@"barHelpTemplatePreviousPage", nil),
                MyLocalizedString(@"barHelpTemplatePagePicker", nil),
                MyLocalizedString(@"barHelpTemplateNextPage", nil)
        ]];
    }else if (EditorViewControllerTypeAnnotations == self.editorViewControllerType)  {
        [templates addObjectsFromArray:@[
                MyLocalizedString(@"barHelpTemplateAnnotationTools", nil),
                MyLocalizedString(@"barHelpTemplatePenAnnotation", nil),
                MyLocalizedString(@"barHelpTemplateDeleteAnnotations", nil),
                MyLocalizedString(@"barHelpTemplateEditorPicker", nil),
                MyLocalizedString(@"barHelpTemplatePreviousPage", nil),
                MyLocalizedString(@"barHelpTemplatePagePicker", nil),
                MyLocalizedString(@"barHelpTemplateNextPage", nil)
        ]];
    }

    return templates;
}

- (NSString *)mainHelpTemplate
{
    switch (self.editorViewControllerType) {
        case EditorViewControllerTypeMeasures:
            return MyLocalizedString(@"mainMeasureEditorHelpTemplate", nil);
        case EditorViewControllerTypeStartMeasure:
            return MyLocalizedString(@"mainStartMeasureEditorHelpTemplate", nil);
        case EditorViewControllerTypeAnnotations:
            return MyLocalizedString(@"mainAnnotationEditorHelpTemplate", nil);
        default:
            return nil;
    }
}

#pragma mark - Utilities

- (BOOL)pdfViewContainsMeasureMarkerRect:(CGRect)measureRect
{
    CGRect pdfRect = CGRectMake(0, 0, self.pdfView.frameWidth, self.pdfView.frameHeight);
    if (CGRectGetMinX(measureRect) < 0) {
        return NO;
    }else if(CGRectGetMaxX(measureRect) > pdfRect.size.width) {
        return NO;
    }else if(CGRectGetMinY(measureRect) < 0) {
        return NO;
    }else if(CGRectGetMaxY(measureRect) > pdfRect.size.height) {
        return NO;
    }
    
    return YES;
}

- (void)showTopToolbarPrompt
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kShowHelpers] && !self.isDismissing) {
        if (nil == self.promptHostingView) {
            self.promptHostingView = [[UIView alloc] initWithFrame:CGRectMake(
                    roundf((self.topToolbar.frameWidth - kStartMeasurePickerPromptWidth) / 2.0f),
                    -kStartMeasurePickerPromptHeight,
                    kStartMeasurePickerPromptWidth,
                    kStartMeasurePickerPromptHeight
            )];
            self.promptHostingView.backgroundColor = [[Helpers black] colorWithAlphaComponent:.7];
            self.promptHostingView.layer.cornerRadius = 8.0;
            self.promptHostingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                    UIViewAutoresizingFlexibleRightMargin;

            self.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                    roundf((kStartMeasurePickerPromptWidth - kStartMeasurePickerPromptLabelWidth) / 2.0f),
                    roundf(
                            (kStartMeasurePickerPromptHeight / 2.0f +
                            (kStartMeasurePickerPromptHeight / 2.0f - kStartMeasurePickerPromptLabelHeight) / 2.0f)
                    ),
                    kStartMeasurePickerPromptLabelWidth,
                    kStartMeasurePickerPromptLabelHeight
            )];
            self.promptLabel.backgroundColor = [UIColor clearColor];
            self.promptLabel.textAlignment = NSTextAlignmentCenter;
            self.promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.promptLabel.textColor = [UIColor whiteColor];

            [self.promptHostingView addSubview:self.promptLabel];
        }

        if (EditorViewControllerTypeStartMeasure == self.editorViewControllerType) {               
            self.promptLabel.numberOfLines = 1;
            self.promptLabel.adjustsFontSizeToFitWidth = YES;
            self.promptLabel.minimumScaleFactor = .5;
            self.promptLabel.font = [UIFont systemFontOfSize:17];
            self.promptLabel.text = MyLocalizedString(@"startMeasurePickerPrompt", nil);
            
        }else if (EditorViewControllerTypeMeasures == self.editorViewControllerType) {     
            self.promptLabel.numberOfLines = 2;
            self.promptLabel.font = [UIFont systemFontOfSize:13.0];
            self.promptLabel.text = MyLocalizedString(@"editorTitlePrompt", nil);
        }

        if (EditorViewControllerTypeMeasures == self.editorViewControllerType ||
            EditorViewControllerTypeStartMeasure == self.editorViewControllerType) 
        {
            [self.view addSubview:self.promptHostingView];
            self.promptHostingView.frameX = roundf((self.topToolbar.frameWidth - kStartMeasurePickerPromptWidth) / 2.0f);
            [UIView animateWithDuration:.25
                             animations:^(void){
                                 self.promptHostingView.frameY = -kStartMeasurePickerPromptHeight / 2.0f;
                             }];
        }
    }
}

- (void)hideTopToolbarPrompt
{
    if (nil != self.promptHostingView) {
        [UIView animateWithDuration:.05
                         animations:^(void) {
                             if (nil != self.promptHostingView) {
                                self.promptHostingView.frameY = -kStartMeasurePickerPromptHeight;
                             }
                         }
                         completion:^(BOOL finished) {
                             [self.promptHostingView removeFromSuperview];
                             self.promptHostingView = nil;
                         }];
    }    
}

#pragma mark -
#pragma mark Overrides

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}


#pragma mark - Validate and dismiss self

- (void)dismissSelf
{
    self.isDismissing = YES;

    if (EditorViewControllerTypeMeasures == self.editorViewControllerType ||
        EditorViewControllerTypeAnnotations == self.editorViewControllerType) 
    {
        
        // Remove any invalid repeats and jumps
        ScoreManager *scoreManager = [ScoreManager sharedInstance];
        NSManagedObjectContext *context = [scoreManager context_];
        
        for (Jump *invalidJump in [scoreManager invalidJumps]) {
            // Set destination measure reference to nil
            // so as to release destination measure reverse reference
            // to the (now deleted) jump
            invalidJump.destinationMeasure = nil;
            if(APP_DEBUG) {
                NSLog(@"Deleting invalid jump: %@", invalidJump);
            }
            [context deleteObject:invalidJump];
        }

        
        for (Repeat *invalidRepeat in [scoreManager invalidRepeats]) {
            if(APP_DEBUG) {
                NSLog(@"Deleting invalid repeat: %@", invalidRepeat);
            }
            [context deleteObject:invalidRepeat];
        }
        
        // Remove jump targets that no jump origin is pointing at
        // Except fine targets as there is no jump type that directly jumps there
        Measure *codaTargetMeasure = [scoreManager targetMeasureForScore:self.score
                                                              andKeyPath:@"coda"];
        if (nil != codaTargetMeasure && 0 == [codaTargetMeasure.jumpDestinations count]) {
            codaTargetMeasure.coda = @NO;
        }
        
        Measure *segnoTargetMeasure = [scoreManager targetMeasureForScore:self.score
                                                               andKeyPath:@"segno"];
        if (nil != segnoTargetMeasure && 0 == [segnoTargetMeasure.jumpDestinations count]) {
            segnoTargetMeasure.segno = @NO;
        }
       
        // Let whoever is interested know that editor produced changes
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEditorWillDismissWithChangesNotification 
                                                                                             object:nil]];
    }
    
    // dissmiss AnnotationsView
    if (nil != self.annotationsView) {
        [self.annotationsView willDissmissAnnotationsView];
        self.annotationsView = nil;
    }
    
    // dissmiss HelpView
    if (nil != self.helpViewController) {
        [self.helpViewController dissmissHelpViewController];
    }
    
    if (nil != self.editorTypeChooserPopoverController) {
        self.editorTypeChooserPopoverController.delegate = nil;
        [self.editorTypeChooserPopoverController dismissPopoverAnimated:NO];
        self.editorTypeChooserPopoverController = nil;
    }
    [self.score refreshPlaytime];
    [[ScoreManager sharedInstance] saveTheFuckingContext];

    if (self.dismissBlock) {
        self.dismissBlock(self.activeStartMeasure);
    }

    [self.promptHostingView removeFromSuperview];
    self.promptHostingView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
