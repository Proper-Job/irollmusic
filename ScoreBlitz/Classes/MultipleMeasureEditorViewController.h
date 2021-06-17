//
//  MultipleMeasureEditorViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 17.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditorViewController;
@class Score;
@class TouchAwareLabel;


@interface MultipleMeasureEditorViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource,
        UIPopoverControllerDelegate>


@property (nonatomic, strong) IBOutlet UIPickerView *tempoPicker, *timeSignaturePicker;
@property (nonatomic, strong) NSSet *measures;
@property (nonatomic, weak) EditorViewController *editorViewController;
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) IBOutlet TouchAwareLabel *multiSelectionTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *firstEndingLabel, *secondEndingLabel, *timeSignatureLabel;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton, *bpmButton, *bpmHelpButton;
@property (nonatomic, strong) IBOutlet UISwitch *primaryEndingSwitch, *secondaryEndingSwitch;
@property (nonatomic, strong) UIPopoverController *bpmHelpPopoverController, *bpmPopoverController;
@property (nonatomic, strong) NSArray *numeratorValues, *denominatorValues;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *timeLabelTopConstraint;
@property (nonatomic, copy) void (^timeSignatureDidChange)(AlpPhoneTimeSignature timeSignature);
@property (nonatomic, copy) void (^bpmDidChange)(NSNumber *bpm);

- (instancetype)initWithMeasures:(NSSet *)theMeasures
                           score:(Score *)theScore
                editorController:(EditorViewController *)editorViewController;

- (IBAction)deleteMarkers;
- (IBAction)primaryEndingDidChange:(id)sender;
- (IBAction)secondaryEndingDidChange:(id)sender;
- (IBAction)showBpmHelpPopover:(id)sender;
- (IBAction)showBpmPopover:(id)sender;
@end
