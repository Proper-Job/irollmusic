//
//  StartMeasureTempoSelectViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TempoSelectViewController.h"
#import "Score.h"
#import "TapTempoInputButton.h"

@implementation TempoSelectViewController

- (id)initWithScore:(Score *)theScore
         completion:(void(^)(NSDictionary *newTempo))completion
{
    self = [super initWithNibName:@"TempoSelectViewController" bundle:nil];
    if (self) {
        self.score = theScore;
        self.completion = completion;
        self.metronomeTicks = [Helpers metronomeTicks];
        self.noteValues = [Helpers noteValues];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = MyLocalizedString(@"setPerformanceTempo", nil);
    
    [self.tapTempoInputButton setTitle:MyLocalizedString(@"buttontapToSetTempo", nil)
                              forState:UIControlStateNormal];
    __weak TempoSelectViewController *weakSelf = self;
    self.tapTempoInputButton.didSelectBpmBlock = ^void(NSNumber *bpm) {
        NSString *noteValue = weakSelf.noteValues[[weakSelf.tempoPicker selectedRowInComponent:0]];

        [weakSelf.tempoPicker selectRow:[weakSelf.metronomeTicks indexOfObject:bpm]
                        inComponent:1
                           animated:NO];

        weakSelf.score.metronomeBpm = bpm;

        NSDictionary *tempo = @{
                kEditorActiveTempoNoteValue : noteValue,
                kEditorActiveTempoBpm : bpm
        };


        if (weakSelf.completion) {
            weakSelf.completion(tempo);
        }
    };
    self.countInBarsLabel.text = MyLocalizedString(@"countInNumberOfBars", nil);
    self.soundSelectionLabel.text = MyLocalizedString(@"metronomeAudible", nil);
    self.optionsHeadingLabel.text = MyLocalizedString(@"metronomeOptionsHeading", nil);
    self.visualMetronomeLabel.text = MyLocalizedString(@"visualMetronome", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.countInBarsSegmentedControl.selectedSegmentIndex = [defaults integerForKey:kMetronomeCountInNumberOfBars];
    self.soundSelectionSwitch.on = [defaults boolForKey:kMetronomeAudible];
    self.visualMetronomeSwitch.on = [defaults boolForKey:kVisualMetronome];
    
    self.tempoPicker.dataSource = self;
    self.tempoPicker.delegate = self;
    
    [self.tempoPicker selectRow:[self.noteValues indexOfObject:self.score.metronomeNoteValue]
                    inComponent:0
                       animated:NO];
    [self.tempoPicker selectRow:[self.metronomeTicks indexOfObject:self.score.metronomeBpm]
                    inComponent:1
                       animated:NO];

    self.preferredContentSize = self.view.frameSize;
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component) {
        return [self.noteValues count];
    }else {
        return [self.metronomeTicks count];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    if (0 == component) {
        UIImage *noteImage = [Helpers noteValueImageForNoteValueString:[self.noteValues objectAtIndex:row]
                                                        imageSpecifier:NoteValueImageSpecifierBlack];

        UIImageView *noteView = (UIImageView *)view;
        if (nil == noteView) {
            noteView = [[UIImageView alloc] initWithImage:noteImage];
        }else {
            noteView.image = noteImage;
        }
        return noteView;
    }else {
        // For some reason returning nil here doesn't cause the picker delegate to call for string titles.
        // Hence this UILabel dance.
        UILabel *label = (UILabel *)view;
        if (nil == label) {
            label = [[UILabel alloc] init];
            label.font = [Helpers avenirNextMediumFontWithSize:18];
            label.textAlignment = NSTextAlignmentCenter;
        }
        label.text = [[self.metronomeTicks objectAtIndex:row] stringValue];
        return label;
    }
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    NSString *noteValue = [self.noteValues objectAtIndex:[self.tempoPicker selectedRowInComponent:0]];
    NSNumber *bpm = [self.metronomeTicks objectAtIndex:[self.tempoPicker selectedRowInComponent:1]];
    
    self.score.metronomeNoteValue = noteValue;
    self.score.metronomeBpm = bpm;
    
    NSDictionary *tempo = @{
            kEditorActiveTempoNoteValue : noteValue,
            kEditorActiveTempoBpm : bpm
    };
    
    if (self.completion) {
        self.completion(tempo);
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32;
}

#pragma mark - Actions

- (IBAction)countInBarsDidChange:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@(self.countInBarsSegmentedControl.selectedSegmentIndex)
                                              forKey:kMetronomeCountInNumberOfBars];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)metronomeAudibleDidChange:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@(self.soundSelectionSwitch.on)
                                              forKey:kMetronomeAudible];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)metronomeVisualDidChange:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@(self.visualMetronomeSwitch.on)
                                              forKey:kVisualMetronome];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
