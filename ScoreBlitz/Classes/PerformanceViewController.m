//
//  PerformanceViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "PerformanceViewController.h"
#import "PerformancePagingViewController.h"
#import "PerformanceScrollingViewController.h"
#import "Score.h"
#import "ScoreManager.h"
#import "Page.h"
#import "Set.h"
#import "ScorePickerTableViewController.h"
#import "EditorViewController.h"
#import "ModePickerView.h"
#import "ToggleToolbarInfoView.h"
#import "SleepManager.h"
#import "SettingsViewController.h"
#import "TrackingManager.h"
#import "AirTurnTextView.h"
#import "PerformanceModePickerTableViewController.h"
#import "ToolbarBackButtonView.h"
#import "ScrollingPngView.h"

@implementation PerformanceViewController

- (id)initWithSet:(Set *)theSet 
            score:(Score *)theScore 
             page:(Page *)thePage
 presentingObject:(id <NSObject>)thePresentingObject
  dismissSelector:(SEL)theDismissSelector
  performanceMode:(PerformanceMode)thePerformanceMode
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.setList = theSet;
        self.score = theScore;
        self.activePage = thePage;
        self.presentingObject = thePresentingObject;
        self.dismissSelector = theDismissSelector;
        self.performanceMode = thePerformanceMode;

        [[SleepManager sharedInstance] addInsomniac:[self sleepIdentifier]];
        
        self.airTurnTextView = [[AirTurnTextView alloc] initWithFrame:CGRectZero];
        self.airTurnTextView.inputView = [[UIView alloc] initWithFrame:CGRectZero];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(observeAirTurnUpArrow:)
                                                     name:kAirTurnUpArrowNotification
                                                   object:self.airTurnTextView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(observeAirTurnDownArrow:)
                                                     name:kAirTurnDownArrowNotification
                                                   object:self.airTurnTextView];
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self.view addSubview:self.airTurnTextView];
    
    //Register for language changed notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeLanguageDidChangNotification:)
                                                 name:kLanguageChanged
                                               object:nil];
    
    self.performanceScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	self.performanceScrollView.scrollsToTop = YES;
    
    self.topToolbar.delegate = self;
    
    self.visiblePages = [NSMutableSet set];
    self.recycledPages = [NSMutableSet set];
    
    //////////////////
    // Toolbar items
    //////////////////
    NSString *pagePickerTitle = [NSString stringWithFormat:MyLocalizedString(@"currentPageIndicator", nil),
                    self.activePageIndex + 1, [self.score.pages count]];
    self.pagePickerItem = [[UIBarButtonItem alloc] initWithTitle:pagePickerTitle
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(togglePagePicker)];
    
    
    self.scorePickerItem = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"buttonScorePicker", nil)
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(showScorePicker:)];

    [[NSBundle mainBundle] loadNibNamed:@"ToolbarBackButtonView" owner:self options:nil];

    __weak PerformanceViewController *weakSelf = self;
    self.backButtonView.backPressedBlock = ^void(UIButton *sender) {
        [weakSelf dismissSelf];
    };
    self.backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButtonView];

    self.helpItem = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"helpBarButtonTitle", nil)
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                                action:@selector(showHelpViewController)];

    self.measureEditorItem = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"editorTypeMeasures", nil)
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showMeasuresEditor)];
    
    self.annotationEditorItem = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"editorTypeAnnotations", nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(showAnnotationsEditor)];
        
    [[NSBundle mainBundle] loadNibNamed:@"ModePickerView" owner:self options:nil];
    self.modePickerView.modeLabel.text = [Helpers localizedPerformanceModeStringForMode:self.performanceMode];
    self.performanceModePickerItem = [[UIBarButtonItem alloc] initWithCustomView:self.modePickerView];
    
    self.settingsItem = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"centralViewSettingsbutton", nil)
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(showSettingsViewController:)];
    
    //////////////////////////////////////////////////////
    // Create gesture recognizer to toggle toolbars
    //////////////////////////////////////////////////////
	self.toolbarToggler = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleToolbars)];
	self.toolbarToggler.numberOfTouchesRequired = 2; // Two fingers
	self.toolbarToggler.numberOfTapsRequired = 1; //  Single tap
    self.toolbarToggler.delegate = self;
    [self.performanceScrollView addGestureRecognizer:self.toolbarToggler];
	
    
    if (nil == self.activePage) {
        self.activePage = [self orderedPagesAsc][0];
    }    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showToggleToolbarInfoView];
    [[TrackingManager sharedInstance] trackGoogleViewWithIdentifier:[Helpers viewTrackingStringForPerformanceMode:self.performanceMode]];
    [self.airTurnTextView becomeFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.topToolbarTopConstraint.constant = self.topLayoutGuide.length;
}


#pragma mark - Popovers

- (IBAction)showModePicker
{
    if (nil == self.modePickerPresentationController) {
        PerformanceModePickerTableViewController *controller = [[PerformanceModePickerTableViewController alloc] initWithPerformanceMode:self.performanceMode
                                                                                                                    modePickedCompletion:^(PerformanceMode newMode)
        {
            if (newMode == self.performanceMode) {
                return;
            }

            PerformanceViewController *newController = nil;
            if (PerformanceModeSimpleScroll == newMode || PerformanceModeAdvancedScroll == newMode) {
                newController = [[PerformanceScrollingViewController alloc] initWithSet:self.setList
                                                                                  score:self.score
                                                                                   page:self.activePage
                                                                        performanceMode:newMode];
            }else {
                newController = [[PerformancePagingViewController alloc] initWithSet:self.setList
                                                                               score:self.score
                                                                                page:self.activePage];
            }
            newController.activePageIndex = self.activePageIndex;
            newController.activeScoreIndex = self.activeScoreIndex;

            self.score.preferredPerformanceMode = @(newMode);
            [[ScoreManager sharedInstance] saveTheFuckingContext];

            [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:@"PerformanceViewController"
                                                                    actionString:kTrackingEventButton
                                                                     labelString:[Helpers eventTrackingStringForPerformanceMode:newMode]
                                                                     valueNumber:@0];

            // Dismiss mode picker
            [self dismissViewControllerAnimated:YES completion:nil];
            self.modePickerPresentationController.delegate = nil;
            self.modePickerPresentationController = nil;

            NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
            if (viewControllers.count > 0) {
                viewControllers[viewControllers.count - 1] = newController;
                [self.navigationController setViewControllers:viewControllers animated:NO];
            }
        }];

        UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        aNavigationController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:aNavigationController
                           animated:YES
                         completion:nil];
        self.modePickerPresentationController = aNavigationController.popoverPresentationController;
        self.modePickerPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        self.modePickerPresentationController.barButtonItem = self.performanceModePickerItem;
        self.modePickerPresentationController.delegate = self;
    }
}


- (void)showScorePicker:(id)sender
{
    if (nil == self.scorePickerPresentationController) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPerformanceControllerWillPresentScorePickerNotification
                                                                                             object:nil]];
        if (nil != self.pagePickerScrollView) {
            [self.pagePickerScrollView hideAnimated:YES];
        }
        ScorePickerTableViewController *controller = [[ScorePickerTableViewController alloc] initWithSet:self.setList
                                                                                        activeScoreIndex:self.activeScoreIndex
                                                                                              completion:^(NSInteger scoreIndex)
        {
            [self dismissViewControllerAnimated:YES
                                   completion:nil];
            self.scorePickerPresentationController = nil;

            if (scoreIndex != self.activeScoreIndex)
            {
              self.activeScoreIndex = scoreIndex;
              self.score = [[self.setList orderedSetListEntriesAsc][scoreIndex] score];
              self.activePage = [self.score orderedPagesAsc][0];

              // Cleanup
              for (id visiblePage in self.visiblePages) {
                  [visiblePage removeFromSuperview];
              }

              self.recycledPages = [NSMutableSet set];
              self.visiblePages = [NSMutableSet set];
              self.orderedPagesAsc = nil;
              self.orderedPagesDesc = nil;

              // Create new
              [self setupCanvas];
              self.performanceScrollView.contentOffset = CGPointZero;
              [self drawPages];

              // Notify interested controllers of the score change
              [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPerformanceControllerDidChangeScoreNotification
                                                                                                   object:nil]];
            }
        }];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        navController.modalPresentationStyle = UIModalPresentationPopover;

        [self presentViewController:navController
                           animated:YES
                         completion:nil];
        self.scorePickerPresentationController = navController.popoverPresentationController;
        self.scorePickerPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        self.scorePickerPresentationController.barButtonItem = sender;
        self.scorePickerPresentationController.delegate = self;
    }
}

// Only called in response to user interaction
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if ([popoverPresentationController isEqual:self.scorePickerPresentationController]) {
        self.scorePickerPresentationController.delegate = nil;
        self.scorePickerPresentationController = nil;
    }else if ([popoverPresentationController isEqual:self.modePickerPresentationController]) {
        self.modePickerPresentationController.delegate = nil;
        self.modePickerPresentationController = nil;
    }
}

- (void)dismissPopovers:(BOOL)animated
{
    if (nil != self.scorePickerPresentationController) {
        self.scorePickerPresentationController.delegate = nil;
        self.scorePickerPresentationController = nil;
    }
    if (nil != self.modePickerPresentationController) {
        self.modePickerPresentationController.delegate = nil;
        self.modePickerPresentationController = nil;
    }

    [self dismissViewControllerAnimated:animated
                             completion:nil];
}



#pragma mark - HelpViewController

- (void)showHelpViewController
{
    self.helpItem.enabled = NO;
    
    if (nil != self.toggleToolbarInfoView) {
        [self.toggleToolbarInfoView.layer removeAllAnimations];
        [self.toggleToolbarInfoView removeFromSuperview];
        self.toggleToolbarInfoView = nil;
    }
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
    }

    [self dismissPopovers:YES];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPerformanceControllerWillPresentHelpViewNotification
                                                                                         object:nil]];
    
    TutorialType type;
    switch (self.performanceMode) {
        case PerformanceModeSimpleScroll:
            type = TutorialTypeSimplePerformance;
            break;
        case PerformanceModeAdvancedScroll:
            type = TutorialTypeAdvancedPerformance;
            break;
        case PerformanceModePage:
            type = TutorialTypePagingPerformance;
            break;
    }

    self.helpViewController = [[HelpViewController alloc] initWithControlItems:[self helpItems]
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
    }];
    self.helpViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.helpViewController.view.alpha = 0;
    
    [self addChildViewController:self.helpViewController];
    [self.helpViewController didMoveToParentViewController:self];
    [self.view addSubview:self.helpViewController.view];
    [self.view bringSubviewToFront:self.helpViewController.view];
    
    NSDictionary *views = @{@"helpView": self.helpViewController.view,
                            @"topToolbar": self.topToolbar,
                            @"bottomToolbar": self.bottomToolbar};
    self.helpViewConstraints = [[NSMutableArray alloc] init];
    [self.helpViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[helpView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views]];
    [self.helpViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topToolbar][helpView][bottomToolbar]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views]];
    [self.view addConstraints:self.helpViewConstraints];
    [UIView animateWithDuration:kHelpViewControllerFadeAnimationDuration
                     animations:^(void) {
                         self.helpViewController.view.alpha = 1;
                     }];

    [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:[Helpers viewTrackingStringForPerformanceMode:self.performanceMode]
                                                            actionString:kTrackingEventButton
                                                             labelString:@"Help"
                                                             valueNumber:@0];
}

#pragma mark - Utilities

- (NSArray *)orderedPagesAsc
{
	if (nil == _orderedPagesAsc) {
		NSSortDescriptor *pageNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number"
                                                                               ascending:YES];
		_orderedPagesAsc = [self.score.pages sortedArrayUsingDescriptors:@[pageNumberDescriptor]];
	}
	return _orderedPagesAsc;
}

- (NSArray *)orderedPagesDesc
{
	if (nil == _orderedPagesDesc) {
		NSSortDescriptor *pageNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number"
                                                                               ascending:NO];
		_orderedPagesDesc = [self.score.pages sortedArrayUsingDescriptors:@[pageNumberDescriptor]];
	}
    
	return _orderedPagesDesc;
}

#pragma mark - Editor

- (void)showMeasuresEditor {
    
    [self dismissPopovers:NO];
    
    // Cause scrolling controller to pause performance
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kWillPresentEditorNotification
                                                                                         object:nil]];
    EditorViewController *editor = [[EditorViewController alloc] initWithScore:self.score
                                                                          page:self.activePage
                                                      editorViewControllerType:EditorViewControllerTypeMeasures
                                                                  dismissBlock:^(Measure *startMeasure) {
                                                                      [self.view setNeedsLayout];
                                                                      [self refreshAnnotations];
                                                                  }];
    [self.navigationController pushViewController:editor animated:YES];
}

- (void)showAnnotationsEditor
{

    [self dismissPopovers:NO];
    
    // Cause scrolling controller to pause performance
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kWillPresentEditorNotification
                                                                                         object:nil]];
    EditorViewController *editor = [[EditorViewController alloc] initWithScore:self.score
                                                                          page:self.activePage
                                                      editorViewControllerType:EditorViewControllerTypeAnnotations
                                                                  dismissBlock:^(Measure *startMeasure)
                                                                  {
                                                                      [self.view setNeedsLayout];
                                                                      [self refreshAnnotations];
                                                                  }];
    [self.navigationController pushViewController:editor animated:YES];
}


#pragma mark - Settings View Controller

- (void)showSettingsViewController:(id)sender
{
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController"
                                                                                  bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}


- (void)observeLanguageDidChangNotification:(NSNotification *)theNotification
{
    self.pagePickerItem.title = [NSString stringWithFormat:MyLocalizedString(@"currentPageIndicator", nil), self.activePageIndex + 1, [self.score.pages count]];
    self.helpItem.title = MyLocalizedString(@"helpBarButtonTitle", nil);
    self.scorePickerItem.title = MyLocalizedString(@"buttonScorePicker", nil);
    self.backItem.title = MyLocalizedString(@"buttonDone", nil);
    self.settingsItem.title = MyLocalizedString(@"centralViewSettingsbutton", nil);
    self.measureEditorItem.title = MyLocalizedString(@"editorTypeMeasures", nil);
    self.annotationEditorItem.title = MyLocalizedString(@"editorTypeAnnotations", nil);
    [[(ModePickerView *)self.performanceModePickerItem.customView modeLabel] setText:[Helpers localizedPerformanceModeStringForMode:self.performanceMode]];    
}

#pragma mark - Toolbars

- (void)toggleToolbars
{
    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
    }

    if (self.topToolbar.hidden) {
        [self showToolbars];
    }else {
        [self hideToolbars];
    }
}

- (void)hideToolbars
{
    [UIView animateWithDuration:kShowHideToolbarAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.topToolbar.alpha = 0;
                         self.bottomToolbar.alpha = 0;
                     } completion:^(BOOL finished) {
         self.topToolbar.hidden = YES;
         self.bottomToolbar.hidden = YES;
         [self showToggleToolbarInfoView];
         [self toolbarsDidHide];
     }];
}

- (void)toolbarsDidHide
{
    [self dismissPopovers:YES];

    if (nil != self.pagePickerScrollView) {
        [self.pagePickerScrollView hideAnimated:YES];
    }
}

- (void)showToolbars
{
    if (nil != self.toggleToolbarInfoView) {
        [self.toggleToolbarInfoView.layer removeAllAnimations];
        [self.toggleToolbarInfoView removeFromSuperview];
        self.toggleToolbarInfoView = nil;
    }

    [UIView animateWithDuration:kShowHideToolbarAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.topToolbar.hidden = NO;
                         self.bottomToolbar.hidden = NO;
                         self.topToolbar.alpha = kToolbarAlphaOpaque;
                         self.bottomToolbar.alpha = kToolbarAlphaOpaque;
                     } completion:^(BOOL finished) {
         ;
     }];
}

- (void)showToggleToolbarInfoView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kShowHelpers]) {
        if (nil == self.toggleToolbarInfoView) {
            [[NSBundle mainBundle] loadNibNamed:@"ToggleToolbarInfoView"
                                          owner:self
                                        options:nil];
            self.toggleToolbarInfoView.frameOrigin = CGPointMake(
                    roundf((self.view.frameWidth - self.toggleToolbarInfoView.frameWidth) / 2.0f),
                    -self.toggleToolbarInfoView.frameHeight
            );
            self.toggleToolbarInfoView.backgroundColor = [[Helpers black] colorWithAlphaComponent:.7];
            self.toggleToolbarInfoView.layer.cornerRadius = 8.0;

            if (self.topToolbar.hidden) {
                self.toggleToolbarInfoView.infoLabel.text = MyLocalizedString(@"showToolbarHelpViewText", nil);
            }else {
                self.toggleToolbarInfoView.infoLabel.text = MyLocalizedString(@"hideToolbarHelpViewText", nil);
            }

            [self.view addSubview:self.toggleToolbarInfoView];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^(void)
                             {
                                 self.toggleToolbarInfoView.frameY = - (self.toggleToolbarInfoView.frameHeight / 2.0f);
                             } completion:^(BOOL finished) {
                 [UIView animateWithDuration:.25
                                       delay:kToolbarToggleHelpViewOnScreenDuration
                                     options:UIViewAnimationOptionAllowUserInteraction
                                  animations:^(void) {
                                      self.toggleToolbarInfoView.frameY = -self.toggleToolbarInfoView.frameHeight;
                                  }
                                  completion:^(BOOL finished) {
                                      [self.toggleToolbarInfoView removeFromSuperview];
                                      self.toggleToolbarInfoView = nil;
                  }];
             }];
        }else {
            if (self.topToolbar.hidden) {
                self.toggleToolbarInfoView.infoLabel.text = MyLocalizedString(@"showToolbarHelpViewText", nil);
            }else {
                self.toggleToolbarInfoView.infoLabel.text = MyLocalizedString(@"hideToolbarHelpViewText", nil);
            }
        }
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    if ([bar isEqual:self.topToolbar]) {
        return UIBarPositionTopAttached;
    } else {
        return UIBarPositionBottom;
    }
}


#pragma mark - Page Picker

- (void)togglePagePicker
{
    if (nil == self.pagePickerScrollView) {
        self.pagePickerScrollView = [[PagePickerScrollView alloc] init];
        self.pagePickerScrollView.pickerDelegate = self;
        self.pagePickerScrollView.padding = kPickerScrollViewPadding;
        self.pagePickerScrollView.activeScore = self.score;
        self.pagePickerScrollView.activePage = self.activePage;
        PagePickerShowAnimation animation = ( [self isKindOfClass:[PerformanceScrollingViewController class]] ) ? PagePickerShowAnimationFromLeft : PagePickerShowAnimationFromBottom;
        [self.pagePickerScrollView showInView:self.view
                                 belowToolbar:[self isKindOfClass:[PerformanceScrollingViewController class]] ? self.topToolbar : self.bottomToolbar
                                withAnimation:animation];
    }else {
        [self.pagePickerScrollView hideAnimated:YES];
    }
}


- (void)pickerScrollViewDidHide:(PagePickerScrollView *)thePickerScrollView
{
    self.pagePickerScrollView = nil;
}

- (void)pickerScrollViewSelectionDidChange:(Page *)newSelection
{
    self.activePage = newSelection;
    [self showPage:self.activePage animated:NO];
}


#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self.toolbarToggler isEqual:gestureRecognizer]) {
        if (nil != self.helpViewController) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Memory Management

- (void)dismissSelf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (nil != self.toggleToolbarInfoView) {
        [self.toggleToolbarInfoView.layer removeAllAnimations];
        [self.toggleToolbarInfoView removeFromSuperview];
        self.toggleToolbarInfoView = nil;
    }
    // dissmiss HelpView
    if (nil != self.helpViewController) {
        [self.helpViewController dissmissHelpViewController];
    }

    [self dismissPopovers:NO];
    [self.score refreshPlaytime];
    [[ScoreManager sharedInstance] saveTheFuckingContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shutdown
{
    [[SleepManager sharedInstance] removeInsomniac:[self sleepIdentifier]];
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        ;
    }
}

- (void)dealloc
{
    [self shutdown];
}

#pragma mark - Abstract Methods

- (void)drawPages
{
    // check subclass implementations
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    // check subclass implementations
    return NO;
}

- (void)showPage:(Page *)thePage animated:(BOOL)animated
{
    // check subclass implementations
}

- (void)setupCanvas
{
    // check subclass implementations
    ;
}

- (NSMutableArray *)topToolbarItems
{
    //Check subclass implementations
    return [NSMutableArray array];
}

- (NSMutableArray *)bottomToolbarItems
{
    //Check subclass implementations
    return [NSMutableArray array];
}

- (NSMutableArray *)helpItems
{
    //Check subclass implementations
    return [NSMutableArray array];
}

- (NSArray *)helpTemplates
{
    return [NSArray array];
}

- (NSString *)mainHelpTemplate
{
    //Check subclass implementations
    return @"";
}

- (NSString *)sleepIdentifier
{
    //Check subclass implementations
    return [NSString stringWithFormat:@"This is not a valid identifier %s %d", __FUNCTION__, __LINE__];
}

- (void)observeAirTurnUpArrow:(NSNotification *)sender
{

}

- (void)observeAirTurnDownArrow:(NSNotification *)sender
{

}

- (void)refreshAnnotations
{

}

@end
