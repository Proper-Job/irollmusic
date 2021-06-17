//
//  EditorViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 21.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagePickerScrollView.h"
#import "AnnotationsView.h"
#import "HelpViewController.h"
#import "EditorTypeChooserTableViewController.h"

@class Page, Score, PdfView, MeasureMarkerView, Measure;
@class ModePickerView, EditorScrollView;
@class ToolbarBackButtonView;


@interface EditorViewController : UIViewController <UIPopoverControllerDelegate, PickerScrollViewDelegate,
        AnnotationsViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIToolbarDelegate>
{
    AlpPhoneTimeSignature activeTimeSignature;
}

@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) Page *activePage;
@property (nonatomic, strong) PdfView *pdfView;
@property (nonatomic, strong) NSMutableSet *measureMarkerViews;
@property (nonatomic, strong) UIPopoverController *markerPopOver, *editorTypeChooserPopoverController,
        *multiMeasurePopover;
@property (nonatomic, strong) NSMutableSet *swipeSelectMeasures, *dragSiblings;
@property (nonatomic, strong) Measure *activeStartMeasure;
@property (nonatomic, assign) EditorViewControllerType editorViewControllerType;
@property (nonatomic, strong) UIBarButtonItem *editorTypeChooserItem;
@property (nonatomic, strong) UIPanGestureRecognizer *swipeSelectRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *pagePickerDismissRecognizer, *addMarkerRecognizer;
@property (nonatomic, assign) BOOL isDismissing, gestureRecognizersDisabled, zoomEnabled;
@property (nonatomic, strong) IBOutlet EditorScrollView *containerScrollView;
@property (nonatomic, strong) IBOutlet UIToolbar *topToolbar, *bottomToolbar;
@property (nonatomic, weak) IBOutlet MeasureMarkerView *measureMarkerView;
@property (nonatomic, strong) IBOutlet ModePickerView *modePickerView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topToolbarTopConstraint;
@property (nonatomic, copy) void (^dismissBlock)(Measure *startMeasure);
@property (nonatomic, strong) UIView *promptHostingView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIBarButtonItem *backItem, *nextPageItem, *previousPageItem, *pagePickerItem, *helpItem;
@property (nonatomic, strong) IBOutlet ToolbarBackButtonView *backButtonView;
@property (nonatomic, strong) NSNumber *activeBpm;
@property (nonatomic, strong) AnnotationsView *annotationsView;
@property (nonatomic, strong) PagePickerScrollView *pagePickerScrollView;
@property (nonatomic, strong) HelpViewController *helpViewController;
@property (nonatomic, strong) NSMutableArray *helpViewConstraints;
@property (nonatomic, assign) MeasureEditorOptionState measureOptionState;
@property (nonatomic, strong) UILabel *promptLabel;

- (instancetype)initWithScore:(Score *)theScore
                         page:(Page *)thePage
     editorViewControllerType:(EditorViewControllerType)type
                 dismissBlock:(void (^)(Measure *startMeasure))dismissBlock;

- (void)previousPage;
- (void)nextPage;
- (void)togglePagePicker;
- (void)dismissPagePickerAnimated;
- (void)dismissPagePicker;
- (void)showHelpViewController;
- (void)deleteMarkerView:(MeasureMarkerView *)measureMarkerView;
- (void)editMeasures:(NSSet *)theMeasures;
- (void)deleteMarkerViewsForMeasures:(NSSet *)theMeasures;
- (void)dismissMultiMarkerPopover;
- (void)dismissMarkerPopover;
- (NSArray *)topToolbarItems;
- (NSArray *)bottomToolbarItems;
- (NSArray *)toolbarHelpItems;
- (IBAction)showModePicker; // used from ModePickerView xib

#define kGrowAnimationDurationSeconds .125
#define kShrinkAnimationDurationSeconds .125

#define kPageTurnAnimationDurationSeconds .35
#define kPageReplaceAnimationDurationSeconds .125

#define kMeasuresConsideredSiblingsDeviation 50.0
#define kMarkerPressedGrow 1.5f
#define kMarkerDraggingGrow 1.2f

#define kSystemIdentificationFormat @"%0.7g"

#define kStartMeasurePickerPromptWidth 350.0f
#define kStartMeasurePickerPromptHeight 104.0f
#define kStartMeasurePickerPromptLabelWidth (kStartMeasurePickerPromptWidth - 10.0f)
#define kStartMeasurePickerPromptLabelHeight roundf(kStartMeasurePickerPromptHeight / 2.0f - 5.0f)

@end
