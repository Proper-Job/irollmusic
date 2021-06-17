//
// Created by Moritz Pfeiffer on 24/03/15.
//

#import "MultipleBpmEditorViewController.h"
#import "TouchAwareLabel.h"
#import "Score.h"
#import "Measure.h"
#import "EditorViewController.h"


@implementation MultipleBpmEditorViewController

- (instancetype)initWithMeasures:(NSSet *)theMeasures
                           score:(Score *)theScore
{
    self = [super initWithNibName:@"MultipleBpmEditorViewController" bundle:nil];
    if (self) {
        self.measures = theMeasures;
        self.score = theScore;
        self.bpmValues = [Helpers bpmValues];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.preferredContentSize = self.view.frame.size;

    self.multiSelectionBpmLabel.text = MyLocalizedString(@"multipleMeasurePropertyValues", nil);
    self.multiSelectionBpmLabel.touchesBegan = ^void(TouchAwareLabel *label){
        label.hidden = YES;
    };

    BOOL measuresShareTempo = YES;
    Measure *sampleMeasure = [self.measures anyObject];

    // Check if measures share tempo
    for (Measure *aMeasure in self.measures) {
        if (![aMeasure.bpm isEqualToNumber:sampleMeasure.bpm]) {
            measuresShareTempo = NO;
            break;
        }
    }

    if (measuresShareTempo) {
        // Restore BPM
        [self.bpmPicker selectRow:[self.bpmValues indexOfObject:sampleMeasure.bpm]
                      inComponent:0
                         animated:NO];
        self.multiSelectionBpmLabel.hidden = YES;
    }else {
        [self.bpmPicker selectRow:[self.bpmValues indexOfObject:@0]
                      inComponent:0
                         animated:NO];
        self.multiSelectionBpmLabel.hidden = NO;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.bpmValues.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.bpmValues[row] stringValue];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSNumber *bpm = self.bpmValues[row];
    [self.measures makeObjectsPerformSelector:@selector(setBpm:)
                                   withObject:bpm];
    if (self.bpmDidChange) {
        self.bpmDidChange(bpm);
    }
}

@end