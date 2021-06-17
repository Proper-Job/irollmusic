//
//  StartMeasureTempoSelectViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Score;
@class TempoSelectViewController;
@class TapTempoInputButton;

@interface TempoSelectViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) IBOutlet UIPickerView *tempoPicker;
@property (nonatomic, strong) IBOutlet TapTempoInputButton *tapTempoInputButton;
@property (nonatomic, strong) IBOutlet UILabel *soundSelectionLabel, *countInBarsLabel, *optionsHeadingLabel, *visualMetronomeLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *countInBarsSegmentedControl;
@property (nonatomic, strong) IBOutlet UISwitch *soundSelectionSwitch, *visualMetronomeSwitch;
@property (nonatomic, strong) NSArray *metronomeTicks, *noteValues;
@property (nonatomic, copy) void (^completion)(NSDictionary *newTempo);

- (id)initWithScore:(Score *)theScore
           completion:(void(^)(NSDictionary *newTempo))completion;


- (IBAction)countInBarsDidChange:(id)sender;
- (IBAction)metronomeAudibleDidChange:(id)sender;
- (IBAction)metronomeVisualDidChange:(id)sender;

@end
