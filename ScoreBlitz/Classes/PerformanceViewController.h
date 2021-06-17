//
//  PerformanceViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagePickerScrollView.h"
#import "ScrollSpeedSelectorViewController.h"
#import "HelpViewController.h"

@class Score;
@class Page;
@class Set;
@class Measure;
@class ModePickerView;
@class ToggleToolbarInfoView;
@class EditorButtonView;
@class AirTurnTextView;
@class ToolbarBackButtonView;

@interface PerformanceViewController : UIViewController <PickerScrollViewDelegate, UIGestureRecognizerDelegate,
        UIToolbarDelegate, UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) Page *activePage;
@property (nonatomic, strong) Set *setList;
@property (nonatomic, strong) NSMutableSet *recycledPages, *visiblePages;
@property (nonatomic, assign) NSInteger activePageIndex;
@property (nonatomic, strong) PagePickerScrollView *pagePickerScrollView;
@property (nonatomic, strong) id <NSObject> presentingObject;
@property (nonatomic, assign) SEL dismissSelector;
@property (nonatomic, assign) NSInteger activeScoreIndex;
@property (nonatomic, assign) PerformanceMode performanceMode;
@property (nonatomic, strong) UIBarButtonItem *pagePickerItem, *scorePickerItem, *backItem, *performanceModePickerItem, *helpItem, *settingsItem, *measureEditorItem, *annotationEditorItem;
@property (nonatomic, strong) NSArray *simplePerformanceToolbarItems, * advancedPerformanceToolbarItems, * pagingPerformanceToolbarItems, *orderedPagesAsc, *orderedPagesDesc;
@property (nonatomic, strong) UIPopoverPresentationController *scorePickerPresentationController,
*modePickerPresentationController;
@property (nonatomic, strong) IBOutlet UIScrollView *performanceScrollView;
@property (nonatomic, strong) IBOutlet UIToolbar *topToolbar, *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIView *performanceIndicatorView;
@property (nonatomic, strong) IBOutlet UILabel *performanceIndicatorLabel;
@property (nonatomic, strong) IBOutlet UIImageView *performanceIndicatorImageView;
@property (nonatomic, strong) IBOutlet ModePickerView *modePickerView;
@property (nonatomic, strong) IBOutlet EditorButtonView *editorButtonView;
@property (nonatomic, strong) IBOutlet ToggleToolbarInfoView *toggleToolbarInfoView;
@property (nonatomic, strong) AirTurnTextView *airTurnTextView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topToolbarTopConstraint;
@property (nonatomic, strong) HelpViewController *helpViewController;
@property (nonatomic, strong) IBOutlet ToolbarBackButtonView *backButtonView;
@property (nonatomic, strong) NSMutableArray *helpViewConstraints;
@property (nonatomic, strong) UITapGestureRecognizer *toolbarToggler;

- (id)initWithSet:(Set *)theSet 
            score:(Score *)theScore 
             page:(Page *)thePage
 presentingObject:(id <NSObject>)thePresentingObject
  dismissSelector:(SEL)theDismissSelector
  performanceMode:(PerformanceMode)thePerformanceMode;

- (NSArray *)orderedPagesAsc;
- (NSArray *)orderedPagesDesc;
- (void)drawPages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)setupCanvas;
- (void)showPage:(Page *)thePage animated:(BOOL)animated;
- (NSMutableArray *)topToolbarItems;
- (NSMutableArray *)bottomToolbarItems;
- (NSMutableArray *)helpItems;
- (NSArray *)helpTemplates;
- (NSString *)mainHelpTemplate;
- (void)hideToolbars;
- (void)toolbarsDidHide;
- (void)showToolbars;
- (void)dismissSelf;
- (NSString *)sleepIdentifier;
- (void)dismissPopovers:(BOOL)animated;
- (void)showHelpViewController;
- (IBAction)showModePicker;
- (void)showSettingsViewController:(id)sender;
- (void)observeLanguageDidChangNotification:(NSNotification *)theNotification;
- (void)shutdown;
- (void)refreshAnnotations;
#define kToolbarAlphaOpaque 1.0
#define kPickerScrollViewPadding 44.0
#define kShowHideToolbarAnimationDuration .25
#define kToolbarToggleHelpViewOnScreenDuration 5.0
@end
