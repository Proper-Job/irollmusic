//
//  MultipleMeasureEditorViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 17.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultipleMeasureEditorViewController.h"
#import "Measure.h"
#import "EditorViewController.h"
#import "ScoreManager.h"
#import "Repeat.h"
#import "Jump.h"
#import "Score.h"
#import "HelpViewPopOverViewController.h"
#import "TouchAwareLabel.h"
#import "MultipleBpmEditorViewController.h"

@interface MultipleMeasureEditorViewController ()
@property (nonatomic, strong) MultipleBpmEditorViewController *bpmEditorViewController;
- (void)refreshMarkerViews;
@end

@implementation MultipleMeasureEditorViewController

- (instancetype)initWithMeasures:(NSSet *)theMeasures
                           score:(Score *)theScore
                editorController:(EditorViewController *)editorViewController
{
    self = [super initWithNibName:@"MultipleMeasureEditorViewController" bundle:nil];
    if (self) {
        self.measures = theMeasures;
        self.score = theScore;
        self.numeratorValues = [Helpers timeSignatureNumeratorValues];
        self.denominatorValues = [Helpers timesignatureDenominatorValues];
        self.editorViewController = editorViewController;
    }
    return self;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.timeLabelTopConstraint.constant = self.topLayoutGuide.length;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.multiSelectionTimeLabel.text = MyLocalizedString(@"multipleMeasurePropertyValues", nil);
    self.multiSelectionTimeLabel.textColor = [UIColor whiteColor];
    self.multiSelectionTimeLabel.touchesBegan = ^void(TouchAwareLabel *label){
        label.hidden = YES;
    };

    self.firstEndingLabel.text = MyLocalizedString(@"primaryEndingLabel", nil);
    self.secondEndingLabel.text = MyLocalizedString(@"secondaryEndingLabel", nil);
    self.timeSignatureLabel.text = MyLocalizedString(@"measureEditorTimeSignature", nil);
    [self.deleteButton setTitle:MyLocalizedString(@"deleteMarkers", nil)
                       forState:UIControlStateNormal];
    [self.bpmButton setTitle:MyLocalizedString(@"measureEditorTempo", nil)
                    forState:UIControlStateNormal];

    BOOL measuresShareTimeSignature = YES;
    Measure *sampleMeasure = [self.measures anyObject];

    // Check if measures share time signature
    for (Measure *aMeasure in self.measures) {
        if (![aMeasure.timeNumerator isEqualToNumber:sampleMeasure.timeNumerator] ||
                ![aMeasure.timeDenominator isEqualToNumber:sampleMeasure.timeDenominator])
        {
            measuresShareTimeSignature = NO;
            break;
        }
    }

    if (measuresShareTimeSignature) {
        // Restore time signature
        [self.timeSignaturePicker selectRow:[sampleMeasure.timeNumerator intValue] -1
                                inComponent:0
                                   animated:NO];

        for (NSNumber *denominator in self.denominatorValues) {
            if ([denominator intValue] == [sampleMeasure.timeDenominator intValue]) {
                [self.timeSignaturePicker selectRow:[self.denominatorValues indexOfObject:denominator]
                                        inComponent:1
                                           animated:NO];
                break;
            }
        }
        self.multiSelectionTimeLabel.hidden = YES;
    }else {
        self.multiSelectionTimeLabel.hidden = NO;
    }

    // Disable primary/secondary switches if necessary
    NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];

    NSSet *eligiblePrimaryMeasures = [self.measures objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        Measure *aMeasure = (Measure *)obj;
        NSInteger myMeasureIndex = [sortedMeasures indexOfObject:aMeasure];

        if (nil != aMeasure.startRepeat) {
            return NO;
        }

        if (nil != aMeasure.endRepeat) {
            return YES;
        }

        NSArray *previousMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(0, myMeasureIndex)]; // exclude aMeasure
        for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
            if (nil != previousMeasure.endRepeat) {
                return NO;
            }
            if (nil != previousMeasure.startRepeat) { // && nil == previousMeasure.startRepeat.endMeasure) {
                return YES;
            }
        }
        return NO;
    }];

    if ([eligiblePrimaryMeasures count] == [self.measures count]) {
        self.primaryEndingSwitch.enabled = YES;

        // Set primary switch state
        BOOL measuresArePrimary = ([[self.measures objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return [[(Measure *)obj primaryEnding] boolValue];
        }] count] == self.measures.count);
        if (measuresArePrimary) {
            self.primaryEndingSwitch.on = YES;
            self.secondaryEndingSwitch.on = NO;
        }
    }else {
        self.primaryEndingSwitch.enabled = NO;
    }

    NSSet *eligibleSecondaryMeasures = [self.measures objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        Measure *aMeasure = (Measure *)obj;
        NSInteger myMeasureIndex = [sortedMeasures indexOfObject:aMeasure];

        if (nil != aMeasure.startRepeat || nil != aMeasure.endRepeat) {
            return NO;
        }

        NSArray *previousMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(0, myMeasureIndex)]; // exclude self.measure
        for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
            if (nil != previousMeasure.startRepeat) {
                return NO;
            }
            if (nil != previousMeasure.endRepeat) {
                return YES;
            }
        }
        return NO;
    }];

    if ([eligibleSecondaryMeasures count] == [self.measures count]) {
        self.secondaryEndingSwitch.enabled = YES;

        // Set secondary switch state
        BOOL measuresAreSecondary = ([[self.measures objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return [[(Measure *)obj secondaryEnding] boolValue];
        }] count] == self.measures.count);
        if (measuresAreSecondary) {
            self.primaryEndingSwitch.on = NO;
            self.secondaryEndingSwitch.on = YES;
        }
    }else {
        self.secondaryEndingSwitch.enabled = NO;
    }

}
#pragma mark - Picker methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component) {
        return self.numeratorValues.count;
    }else {
        return self.denominatorValues.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (0 == component) {
        return [self.numeratorValues[row] stringValue];
    }else {
        return [self.denominatorValues[row] stringValue];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    AlpPhoneTimeSignature timeSignature;
    timeSignature.numerator = [[self.numeratorValues objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
    timeSignature.denominator = [[self.denominatorValues objectAtIndex:[pickerView selectedRowInComponent:1]] intValue];

    for (Measure *aMeasure in self.measures) {
        aMeasure.timeNumerator = @(timeSignature.numerator);
        aMeasure.timeDenominator = @(timeSignature.denominator);
    }

    [self refreshMarkerViews];
    if (self.timeSignatureDidChange) {
        self.timeSignatureDidChange(timeSignature);
    }
}

#pragma mark -


- (IBAction)primaryEndingDidChange:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;

    [self.measures makeObjectsPerformSelector:@selector(setPrimaryEnding:)
                                   withObject:@(theSwitch.on)];
    if (theSwitch.on) {
        [self.measures makeObjectsPerformSelector:@selector(setSecondaryEnding:)
                                       withObject:@NO];
        self.secondaryEndingSwitch.on = NO;
    }
    [self refreshMarkerViews];
}

- (IBAction)secondaryEndingDidChange:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;

    [self.measures makeObjectsPerformSelector:@selector(setSecondaryEnding:)
                                   withObject:@(theSwitch.on)];

    if (theSwitch.on) {
        [self.measures makeObjectsPerformSelector:@selector(setPrimaryEnding:)
                                       withObject:@NO];
        self.primaryEndingSwitch.on = NO;
    }
    [self refreshMarkerViews];
}

- (void)refreshMarkerViews
{
    [[self.editorViewController.measureMarkerViews filteredSetUsingPredicate:
            [NSPredicate predicateWithFormat:@"measure IN %@", self.measures]]
            makeObjectsPerformSelector:@selector(refreshSymbols)];
}

- (IBAction)deleteMarkers
{
    NSManagedObjectContext *context = [[ScoreManager sharedInstance] context_];
    ScoreManager *scoreManager = [ScoreManager sharedInstance];

    [self.editorViewController deleteMarkerViewsForMeasures:self.measures];

    // Delete measures
    for (Measure *aMeasure in self.measures) {
        [context deleteObject:aMeasure];
    }

    // Remove primary/secondary endings
    NSMutableSet *keepers = [[NSMutableSet alloc] initWithCapacity:[self.measures count]];
    NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];
    for (Measure *goner in self.measures) {
        if (nil != goner.startRepeat || nil != goner.endRepeat) {

            NSInteger myMeasureIndex = [sortedMeasures indexOfObject:goner];
            NSArray *nextMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(myMeasureIndex + 1, [sortedMeasures count] - (myMeasureIndex + 1))]; // Exclude aMeasure

            if (nil != goner.startRepeat) {
                // Remove first endings
                for (Measure *nextMeasure in nextMeasures) {
                    if (![nextMeasure isDeleted]) {
                        [keepers addObject:nextMeasure];
                    }
                    nextMeasure.primaryEnding = @NO;
                    if (nil != nextMeasure.startRepeat || nil != nextMeasure.endRepeat) {
                        break;
                    }
                }
            }
            if (nil != goner.endRepeat) {
                NSArray *previousMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(0, myMeasureIndex)]; // exclude aMeasure
                // Remove primary endings
                for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
                    if (![previousMeasure isDeleted]) {
                        [keepers addObject:previousMeasure];
                    }
                    previousMeasure.primaryEnding = @NO;
                    if (nil != previousMeasure.endRepeat || nil != previousMeasure.startRepeat) {
                        break;
                    }
                }

                // Remove secondary endings
                for (Measure *nextMeasure in nextMeasures) {
                    if (![nextMeasure isDeleted]) {
                        [keepers addObject:nextMeasure];
                    }
                    nextMeasure.secondaryEnding = @NO;
                    if (nil != nextMeasure.startRepeat || nil != nextMeasure.endRepeat) {
                        break;
                    }
                }
            }
        }
    }
    [[self.editorViewController.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure IN %@", keepers]] makeObjectsPerformSelector:@selector(refreshSymbols)];


    self.measures = nil;

    // Match up dangling repeats    
    [scoreManager matchDanglingRepeatsForScore:self.score];

    // Delete zombie repeats
    for (Repeat *zombieRepeat in [scoreManager zombieRepeats]) {
        [context deleteObject:zombieRepeat];
    }

    // Delete zombie jumps
    for (Jump *zombieJump in [scoreManager zombieJumps]) {
        [context deleteObject:zombieJump];
    }

    [self.editorViewController dismissMultiMarkerPopover];
}


#pragma mark - Popovers

- (IBAction)showBpmHelpPopover:(id)sender
{
    if (nil == self.bpmHelpPopoverController) {
        HelpViewPopOverViewController *controller = [[HelpViewPopOverViewController alloc] initWithTemplate:MyLocalizedString(@"popoverHelpTemplateBpm", nil)
                                                                                                controlItem:sender
                                                                                        webViewFinishedLoad:^(id controlItem)
        {
            [self.bpmHelpPopoverController presentPopoverFromRect:self.bpmHelpButton.frame
                                                           inView:self.view
                                         permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                                         animated:YES];
        }];
        self.bpmHelpPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.bpmHelpPopoverController.delegate = self;
        [controller loadContent];
    }
}

- (IBAction)showBpmPopover:(id)sender {
    if (nil == self.bpmPopoverController) {
        MultipleBpmEditorViewController *controller = [[MultipleBpmEditorViewController alloc] initWithMeasures:self.measures
                                                                                          score:self.score];
        controller.bpmDidChange = self.bpmDidChange;
        self.bpmPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.bpmPopoverController.delegate = self;
        [self.bpmPopoverController presentPopoverFromRect:self.bpmButton.frame
                                                   inView:self.view
                                 permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                                 animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController { // Is not called in response to programatic dismissal
    if ([popoverController isEqual:self.bpmHelpPopoverController]) {
        self.bpmHelpPopoverController.delegate = nil;
        self.bpmHelpPopoverController = nil;
    }else if ([popoverController isEqual:self.bpmPopoverController]) {
        self.bpmPopoverController.delegate = nil;
        self.bpmPopoverController = nil;
    }
}

@end
