//
//  MeasureEditorViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 22.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionSheetCustomPickerDelegate.h"

@class Measure;
@class EditorViewController;
@class MeasureMarkerView;
@class Score;

@interface MeasureEditorViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate,
        UIPopoverControllerDelegate, ActionSheetCustomPickerDelegate>

@property (nonatomic, strong) Measure *measure;
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) EditorViewController *editorController;
@property (nonatomic, strong) MeasureMarkerView *markerView;
@property (nonatomic, strong) IBOutlet UIPickerView *timeSignaturePicker;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *optionsDisclosureImageView;
@property (nonatomic, assign) MeasureEditorOptionState measureOptionState;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton, *bpmHelpButton;
@property (nonatomic, strong) UIPopoverController *bpmHelpPopoverController;
@property (nonatomic, strong) NSArray *numeratorValues, *denominatorValues, *bpmValues;
@property (nonatomic, strong) NSSet *advancedSwitchOptions, *advancedTakeRepeatsOptions;
@property (nonatomic, strong) IBOutlet UISegmentedControl *numberOfRepeatsSegmentedControl;
@property (nonatomic, strong) IBOutlet UISwitch *endRepeat, *primaryEnding, *secondaryEnding, *startRepeat, *coda,
        *goToCoda, *daCapo, *daCapoAlFine, *daCapoAlSegno, *dalSegno, *fine, *segno, *dalSegnoAlFine, *dalSegnoAlCoda,
        *daCapoAlCoda;

@property (nonatomic, strong) IBOutlet UILabel *timeSignatureLabel, *startRepeatLabel, *endRepeatLabel,
        *primaryEndingLabel, *secondaryEndingLabel, *numberOfRepeatsLabel, *optionsDisclosureLabel, *codaLabel,
        *goToCodaLabel, *daCapoLabel,
*daCapoAlFineLabel, *daCapoAlSegnoLabel, *dalSegnoLabel, *fineLabel, *segnoLabel, *dalSegnoAlFineLabel,
        *dalSegnoAlCodaLabel, *daCapoAlCodaLabel;

@property (nonatomic, strong) IBOutlet UIButton *dalSegnoTakeRepeats, *dalSegnoAlFineTakeRepeats,
        *dalSegnoAlCodaTakeRepeats, *daCapoTakeRepeats, *daCapoAlCodaTakeRepeats, *daCapoAlFineTakeRepeats,
        *daCapoAlSegnoTakeRepeats, *bpmButton;
@property (nonatomic, copy) void (^timeSignatureDidChange)(AlpPhoneTimeSignature timeSignature);
@property (nonatomic, copy) void (^measureOptionStateDidChange)(MeasureEditorOptionState measureOptionState);
@property (nonatomic, copy) void (^bpmDidChange)(NSNumber *bpm);

- (id)initWithMeasure:(Measure *)theMeasure
                score:(Score *)theScore
           markerView:(MeasureMarkerView *)theMarkerView
          optionState:(MeasureEditorOptionState)theOptionState
     editorController:(EditorViewController *)theEditorController;

- (IBAction)deleteMarker;
- (IBAction)toggleOptions:(id)sender;
- (IBAction)showBpmHelpPopover:(id)sender;
- (IBAction)showBpmPicker:(id)sender;

- (CGSize)optionStateNormalSize;
- (CGSize)optionStateDetailedSize;

// Repeats
- (IBAction)startRepeatChanged:(id)sender;
- (IBAction)endRepeatChanged:(id)sender;
- (IBAction)repeatCountChanged:(id)sender;
- (IBAction)primaryEndingChanged:(id)sender;
- (IBAction)secondaryEndingChanged:(id)sender;
- (IBAction)takeRepeatsChanged:(id)sender;

// Targets
- (IBAction)segnoChanged:(id)sender;
- (IBAction)fineChanged:(id)sender;
- (IBAction)codaChanged:(id)sender;
- (IBAction)goToCodaChanged:(id)sender;

- (IBAction)segnoJumpOriginChanged:(id)sender;
- (IBAction)daCapoJumpOriginChanged:(id)sender;

#define kDeleteButtonMarginBottom 8
#define kToggleOptionsDuration .35
@end
