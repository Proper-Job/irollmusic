//
//  MeasureEditorViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 22.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "MeasureEditorViewController.h"
#import "EditorViewController.h"
#import "Measure.h"
#import "MeasureMarkerView.h"
#import "ScoreManager.h"
#import "Score.h"
#import "Repeat.h"
#import "Jump.h"
#import "HelpViewPopOverViewController.h"
#import "ActionSheetCustomPicker.h"

@interface MeasureEditorViewController ()
- (void)configureEditorViewForOptionState:(MeasureEditorOptionState)state 
						animationDuration:(NSTimeInterval)duration;
- (void)validateInputAndSyncUI;
- (void)setSelectedRepeatCountIndex:(NSInteger)count;
@end


@implementation MeasureEditorViewController

#pragma mark - Initialization


- (id)initWithMeasure:(Measure *)theMeasure
                score:(Score *)theScore
           markerView:(MeasureMarkerView *)theMarkerView
          optionState:(MeasureEditorOptionState)theOptionState
     editorController:(EditorViewController *)theEditorController
{
    self = [super initWithNibName:@"MeasureEditorViewController" bundle:nil];
    if (self) {

        self.measure = theMeasure;
        self.score = theScore;
        self.markerView = theMarkerView;
        self.measureOptionState = theOptionState;
        self.editorController = theEditorController;

        self.numeratorValues = [Helpers timeSignatureNumeratorValues];
        self.denominatorValues = [Helpers timesignatureDenominatorValues];
        self.bpmValues = [Helpers bpmValues];

		self.advancedSwitchOptions = [[NSSet alloc] initWithObjects:
                            @"coda",
                            @"goToCoda",
                            @"daCapo",
							@"daCapoAlFine",
                            @"daCapoAlSegno",
                            @"dalSegno",
                            @"fine",
                            @"segno",
                            @"dalSegnoAlFine",
                            @"dalSegnoAlCoda",
                            @"daCapoAlCoda", nil];
        self.advancedTakeRepeatsOptions = [[NSSet alloc] initWithObjects:
                @"dalSegnoTakeRepeats",
                @"dalSegnoAlFineTakeRepeats",
                @"dalSegnoAlCodaTakeRepeats",
                @"daCapoTakeRepeats",
                @"daCapoAlCodaTakeRepeats",
                @"daCapoAlFineTakeRepeats",
                @"daCapoAlSegnoTakeRepeats",
                @"bpmButton",
                @"bpmHelpButton", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.deleteButton setBackgroundImage:[Helpers imageFromColor:[Helpers red]]
                                 forState:UIControlStateNormal];
    [self.bpmButton setBackgroundImage:[Helpers imageFromColor:[Helpers petrol]]
                              forState:UIControlStateNormal];
    
    // Set switch tags
    self.dalSegno.tag = APJumpTypeDalSegno;
    self.dalSegnoAlCoda.tag = APJumpTypeDalSegnoAlCoda;
    self.dalSegnoAlFine.tag = APJumpTypeDalSegnoAlFine;
    self.daCapo.tag = APJumpTypeDaCapo;
    self.daCapoAlCoda.tag = APJumpTypeDaCapoAlCoda;
    self.daCapoAlFine.tag = APJumpTypeDaCapoAlFine;
    self.daCapoAlSegno.tag = APJumpTypeDaCapoAlSegno;
    
	// Restore time signature
	[self.timeSignaturePicker selectRow:[self.measure.timeNumerator intValue] -1
                            inComponent:0
                               animated:NO];
	
	for (NSNumber *denominator in self.denominatorValues) {
		if ([denominator intValue] == [self.measure.timeDenominator intValue]) {
			[self.timeSignaturePicker selectRow:[self.denominatorValues indexOfObject:denominator]
                                    inComponent:1
                                       animated:NO];
			break;
		}
	}

	[self validateInputAndSyncUI];
    
    [self configureEditorViewForOptionState:self.measureOptionState
						  animationDuration:0];
    
    self.primaryEndingLabel.text = MyLocalizedString(@"primaryEndingLabel", nil);
    self.secondaryEndingLabel.text = MyLocalizedString(@"secondaryEndingLabel", nil);
    self.timeSignatureLabel.text = MyLocalizedString(@"measureEditorTimeSignature", nil);
    self.startRepeatLabel.text = MyLocalizedString(@"measureEditorStartRepeat", nil);
    self.endRepeatLabel.text = MyLocalizedString(@"measureEditorEndRepeat", nil);
    self.numberOfRepeatsLabel.text = MyLocalizedString(@"measureEditorNumberOfPasses", nil);
    self.goToCodaLabel.text = MyLocalizedString(@"measureEditorGoToCoda", nil);
    [self.deleteButton setTitle:MyLocalizedString(@"deleteMarker", nil) forState:UIControlStateNormal];
    [self.bpmButton setTitle:MyLocalizedString(@"measureEditorTempo", nil) forState:UIControlStateNormal];
}

#pragma mark - Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([self.timeSignaturePicker isEqual:pickerView]) {
        return 2;
    }else {
        return 1;
    }

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([self.timeSignaturePicker isEqual:pickerView]) {
        if (0 == component) {
            return self.numeratorValues.count;
        } else {
            return self.denominatorValues.count;
        }
    }else {
        return self.bpmValues.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.timeSignaturePicker isEqual:pickerView]) {
        if (0 == component) {
            return [self.numeratorValues[row] stringValue];
        } else {
            return [self.denominatorValues[row] stringValue];
        }
    }else {
        return [self.bpmValues[row] stringValue];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([self.timeSignaturePicker isEqual:pickerView]) {
        AlpPhoneTimeSignature timeSignature;
        timeSignature.numerator = [self.numeratorValues[(NSUInteger) [pickerView selectedRowInComponent:0]] intValue];
        timeSignature.denominator = [self.denominatorValues[(NSUInteger) [pickerView selectedRowInComponent:1]] intValue];

        NSString *numerator = [NSString stringWithFormat:@"%d", timeSignature.numerator];
        NSString *denominator = [NSString stringWithFormat:@"%d", timeSignature.denominator];

        self.measure.timeNumerator = @(timeSignature.numerator);
        self.measure.timeDenominator = @(timeSignature.denominator);
        self.markerView.numerator.text = numerator;
        self.markerView.denominator.text = denominator;

        if (self.timeSignatureDidChange) {
            self.timeSignatureDidChange(timeSignature);
        }
    }else {
        NSNumber *bpm = self.bpmValues[row];
        self.measure.bpm = bpm;
        if (self.bpmDidChange) {
            self.bpmDidChange(bpm);
        }
    }
}

#pragma mark -

- (IBAction)toggleOptions:(id)sender
{
	self.measureOptionState = (MeasureEditorOptionState) !self.measureOptionState;
	[self configureEditorViewForOptionState:self.measureOptionState animationDuration:kToggleOptionsDuration];
    if (self.measureOptionStateDidChange) {
        self.measureOptionStateDidChange(self.measureOptionState);
    }
}


- (void)configureEditorViewForOptionState:(MeasureEditorOptionState)state 
						animationDuration:(NSTimeInterval)duration
{
	CGSize contentSize;
	
	if (MeasureEditorOptionStateNormal == state) {
		contentSize = [self optionStateNormalSize];
	}else {
		contentSize = [self optionStateDetailedSize];
	}

    self.scrollView.contentSize = contentSize;
    [self.editorController.markerPopOver setPopoverContentSize:CGSizeMake(contentSize.width, contentSize.height +
                    self.navigationController.navigationBar.frameHeight) // self.topLayoutGuide.length is not set yet
                                                      animated:YES];
	
	[UIView animateWithDuration:duration
					 animations:^(void){
						 if (MeasureEditorOptionStateNormal == state) {
							 self.optionsDisclosureImageView.transform = CGAffineTransformIdentity;
							 self.optionsDisclosureLabel.text = MyLocalizedString(@"pressForMoreOptions", nil);

							 for (NSString *optionSwitch in self.advancedSwitchOptions) {
                                 [[self valueForKey:optionSwitch] setAlpha:0];
                                 [[self valueForKey:[optionSwitch stringByAppendingString:@"Label"]] setAlpha:0];
                             }
                             for (NSString *takeRepeatsOption in self.advancedTakeRepeatsOptions) {
                                 [[self valueForKey:takeRepeatsOption] setAlpha:0];
                             }
                             self.deleteButton.frameY = self.bpmButton.frameY;
						 }else {
							 self.optionsDisclosureImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
							 self.optionsDisclosureLabel.text = MyLocalizedString(@"pressForLessOptions", nil);

							 for (NSString *optionSwitch in self.advancedSwitchOptions) {
								 [[self valueForKey:optionSwitch] setAlpha:1.0];
								 [[self valueForKey:[optionSwitch stringByAppendingString:@"Label"]] setAlpha:1.0];
							 }
                             for (NSString *takeRepeatsOption in self.advancedTakeRepeatsOptions) {
                                 [[self valueForKey:takeRepeatsOption] setAlpha:1.0];
                             }
                             self.deleteButton.frameY = contentSize.height - self.deleteButton.frameHeight -
                                     kDeleteButtonMarginBottom;
						 }
					 }];
}

- (CGSize)optionStateNormalSize
{
    CGSize size = CGSizeMake(320, 551);
    return size;
}

- (CGSize)optionStateDetailedSize
{
    CGSize size = CGSizeMake(320, 1017);
    return size;
}


#pragma mark - Sync UI and Validate

- (IBAction)deleteMarker
{
    NSManagedObjectContext *context = [[ScoreManager sharedInstance] context_];
    ScoreManager *scoreManager = [ScoreManager sharedInstance];
    
    // Remove primary/secondary endings
    if (nil != self.measure.startRepeat || nil != self.measure.endRepeat) {
        NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];
        NSInteger myMeasureIndex = [sortedMeasures indexOfObject:self.measure];
        NSArray *nextMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(myMeasureIndex + 1, [sortedMeasures count] - (myMeasureIndex + 1))]; // Exclude self.measure
        NSMutableSet *morphers = [[NSMutableSet alloc] init];
        
        if (nil != self.measure.startRepeat) {
            // Remove first endings
            for (Measure *nextMeasure in nextMeasures) {
                [morphers addObject:nextMeasure];
                nextMeasure.primaryEnding = @NO;
                if (nil != nextMeasure.startRepeat || nil != nextMeasure.endRepeat) {
                    break;
                }  
            }
        }
        if (nil != self.measure.endRepeat) {
            NSArray *previousMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(0, myMeasureIndex)]; // exclude self.measure
            // Remove primary endings
            for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
                [morphers addObject:previousMeasure];
                previousMeasure.primaryEnding = @NO;
                if (nil != previousMeasure.endRepeat || nil != previousMeasure.startRepeat) {
                    break;
                }
            }
            
            // Remove secondary endings
            for (Measure *nextMeasure in nextMeasures) {
                [morphers addObject:nextMeasure];
                nextMeasure.secondaryEnding = @NO;
                if (nil != nextMeasure.startRepeat || nil != nextMeasure.endRepeat) {
                    break;
                }
            }
        }
        
        [[self.editorController.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure IN %@", morphers]] makeObjectsPerformSelector:@selector(refreshSymbols)];
    }
    
    // Delete measure
    [context deleteObject:self.measure];
    self.measure = nil;
    
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
    
    // Delete marker view
    [self.editorController deleteMarkerView:self.markerView];
    
    // Dismiss popover
    [self.editorController dismissMarkerPopover];
}


- (void)validateInputAndSyncUI
{
    Measure *myMeasure = self.measure;
    APJumpType jumpType = (nil != self.measure.jumpOrigin) ? [self.measure.jumpOrigin.jumpType intValue] : APJumpTypeNone;
    NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];
    NSInteger myMeasureIndex = [sortedMeasures indexOfObject:myMeasure];
    ScoreManager *scoreManager = [ScoreManager sharedInstance];
    
    /******************************
    * Enable / disable controls
    ******************************/
    
    
    // Currently I think it is important to enable jump origins within
    // and including repeats :: moritz 21.7.2011
    BOOL disableJumpOrigins = NO; // Use this to disable jump origins later
    
    ///////////////////////////////
    // Validate Repeats
    ///////////////////////////////
    NSArray *repeats = [scoreManager allRepeatsForScore:self.score];
    BOOL startRepeatEnabled = YES;
    BOOL endRepeatEnabled = NO;
    BOOL primaryEndingEnabled = NO;
    BOOL secondaryEndingEnabled = NO;
    BOOL continueValidatingRepeats = YES;
    
    // Check if secondary ending can be placed
    for (Repeat *aRepeat in repeats) {
        Measure *endMeasure = aRepeat.endMeasure;
        if (nil != endMeasure && [sortedMeasures indexOfObject:endMeasure] < myMeasureIndex) {
            secondaryEndingEnabled = YES;
            break;
        }
    }

    
    // Disallow putting a new repeat within an existing 'repeat block'
    for (Repeat *aRepeat in repeats) {
        Measure *startMeasure = aRepeat.startMeasure;
        Measure *endMeasure = aRepeat.endMeasure;
        
        if (nil != startMeasure && nil != endMeasure) {
            if ([sortedMeasures indexOfObject:startMeasure] < myMeasureIndex && [sortedMeasures indexOfObject:endMeasure] > myMeasureIndex) {
                startRepeatEnabled = NO;
                endRepeatEnabled = NO;
                primaryEndingEnabled = YES;
                //secondaryEndingEnabled = NO;
                disableJumpOrigins = NO;
                continueValidatingRepeats = NO;
                break;
            }
        }
    }
    
    // Check if this measure is an existing start repeat
    if (continueValidatingRepeats) {
        if (nil != myMeasure.startRepeat) {
            startRepeatEnabled = YES;
            endRepeatEnabled = NO;
            primaryEndingEnabled = NO;
            //secondaryEndingEnabled = NO;
            disableJumpOrigins = NO;
            continueValidatingRepeats = NO;
        }
    }
    
    // Check if this measure is an existing end repeat
    if (continueValidatingRepeats) {
        if (nil != myMeasure.endRepeat) {
            startRepeatEnabled = NO;
            endRepeatEnabled = YES;
            primaryEndingEnabled = YES;
            //secondaryEndingEnabled = NO;
            disableJumpOrigins = NO;
            continueValidatingRepeats = NO;
        }
    }
    
    
    // Allow end repeat only if 'dangling' start repeat is present and has a smaller index
    if (continueValidatingRepeats) {
        for (Repeat *aRepeat in repeats) {
            Measure *startMeasure = aRepeat.startMeasure;
            Measure *endMeasure = aRepeat.endMeasure;
            
            if (nil != startMeasure && nil == endMeasure && [sortedMeasures indexOfObject:startMeasure] < myMeasureIndex) {
                startRepeatEnabled = NO;
                endRepeatEnabled = YES;
                primaryEndingEnabled = YES;
                //secondaryEndingEnabled = NO;
                continueValidatingRepeats = NO;
                break;
            }
        }
    }
    
//    // Enable 2nd ending whenever measure preceded by an end repeat
//    if (continueValidatingRepeats) {
//        for (Repeat *aRepeat in repeats) {
//            Measure *endMeasure = aRepeat.endMeasure;
//            if (nil != endMeasure && [sortedMeasures indexOfObject:endMeasure] < myMeasureIndex) {
//                startRepeatEnabled = YES;
//                endRepeatEnabled = NO;
//                primaryEndingEnabled = NO;
//                secondaryEndingEnabled = YES;
//                continueValidatingRepeats = NO;
//                break;
//            }
//        }
//    }   
    
    self.startRepeat.enabled = startRepeatEnabled;
    self.endRepeat.enabled = endRepeatEnabled;
    self.primaryEnding.enabled = primaryEndingEnabled;
    self.secondaryEnding.enabled = secondaryEndingEnabled;
//    self.repeatCountMaskImageView.hidden = (nil != myMeasure.startRepeat || nil != myMeasure.endRepeat);
    
    ///////////////////////////////
    // Validate Jump targets
    ///////////////////////////////
    Measure *codaMeasure = [scoreManager targetMeasureForScore:self.score
                                                    andKeyPath:@"coda"];
    Measure *fineMeasure = [scoreManager targetMeasureForScore:self.score
                                                    andKeyPath:@"fine"];
    Measure *segnoMeasure = [scoreManager targetMeasureForScore:self.score
                                                     andKeyPath:@"segno"];
    
    BOOL codaEnabled = YES;
    BOOL fineEnabled = YES;
    BOOL segnoEnabled = YES;
   
    if (nil != codaMeasure) {
        if ([codaMeasure isEqual:myMeasure]) {
            codaEnabled = YES;
            fineEnabled = NO;
            segnoEnabled = NO;
        }else {
            codaEnabled = NO;
        }
    }else if (APJumpTypeGoToCoda == jumpType) {
        codaEnabled = NO;
    }
    
    if (nil != fineMeasure) {
        if ([fineMeasure isEqual:myMeasure]) {
            fineEnabled = YES;
            codaEnabled = NO;
            segnoEnabled = NO;
        }else {
            fineEnabled = NO;
        }
    }
    
    if (nil != segnoMeasure) {
        if ([segnoMeasure isEqual:myMeasure]) {
            segnoEnabled = YES;
            codaEnabled = NO;
            fineEnabled = NO;
        }else {
            segnoEnabled = NO;
        }
    }else if (APJumpTypeDalSegno == jumpType || APJumpTypeDalSegnoAlCoda == jumpType || APJumpTypeDalSegnoAlFine == jumpType) {
        segnoEnabled = NO;
    }
    
    self.coda.enabled = codaEnabled;
    self.fine.enabled = fineEnabled;
    self.segno.enabled = segnoEnabled;
    
    ///////////////////////////////
    // Validate Jump origins
    ///////////////////////////////
    
    BOOL goToCodaEnabled = YES;
    BOOL dalSegnoEnabled = YES;
    BOOL dalSegnoAlCodaEnabled = YES;
    BOOL dalSegnoAlFineEnabled = YES;
    BOOL daCapoEnabled = YES;
    BOOL daCapoAlCodaEnabled = YES;
    BOOL daCapoAlFineEnabled = YES;
    BOOL daCapoAlSegnoEnabled = YES;
    
    if (disableJumpOrigins) {
        goToCodaEnabled = NO;
        dalSegnoEnabled = NO;
        dalSegnoAlCodaEnabled = NO;
        dalSegnoAlFineEnabled = NO;
        daCapoEnabled = NO;
        daCapoAlCodaEnabled = NO;
        daCapoAlFineEnabled = NO;
        daCapoAlSegnoEnabled = NO;
    }else {
        // Disallow multiple coda jumps
        // Disallow coda and goToCoda to be the same measure
        if ([myMeasure.coda boolValue]) {
            goToCodaEnabled = NO;
        }else {
            Jump *codaJump =  [scoreManager jumpForScore:self.score andJumpType:APJumpTypeGoToCoda]; // can be nil
            if ((nil != codaJump.originMeasure && codaJump.originMeasure != myMeasure) || 
                (nil != myMeasure.jumpOrigin && APJumpTypeGoToCoda != jumpType))
            {
                goToCodaEnabled = NO;
            }
        }
        
        
        // Disallow multiple D.S., D.S. al Fine, D.S. al Coda jumps
        // Disallow segno and 'segno type' jump origins to be the same measure
        if ([myMeasure.segno boolValue]) {
            dalSegnoEnabled = NO;
            dalSegnoAlFineEnabled = NO;
            dalSegnoAlCodaEnabled = NO;
        }else {
            NSArray *segnoJumpTypes = @[
                    @(APJumpTypeDalSegno),
                    @(APJumpTypeDalSegnoAlFine),
                    @(APJumpTypeDalSegnoAlCoda)
            ];
            for (NSNumber *currentJumpTypeNumber in segnoJumpTypes) {
                APJumpType currentJumpType = [currentJumpTypeNumber intValue];
                
                if (nil != myMeasure.jumpOrigin && currentJumpType != jumpType) {
                    if (APJumpTypeDalSegno == currentJumpType) {
                        dalSegnoEnabled = NO;
                    }else if (APJumpTypeDalSegnoAlFine == currentJumpType) {
                        dalSegnoAlFineEnabled = NO;
                    }else if (APJumpTypeDalSegnoAlCoda == currentJumpType) {
                        dalSegnoAlCodaEnabled = NO;
                    }
                }else {
                    // Do the core data query only if absolutely necessary
                    Jump *aJump = [scoreManager jumpForScore:self.score andJumpType:currentJumpType];
                    if (nil != aJump.originMeasure && aJump.originMeasure != myMeasure){
                        if (APJumpTypeDalSegno == currentJumpType) {
                            dalSegnoEnabled = NO;
                        }else if (APJumpTypeDalSegnoAlFine == currentJumpType) {
                            dalSegnoAlFineEnabled = NO;
                        }else if (APJumpTypeDalSegnoAlCoda == currentJumpType) {
                            dalSegnoAlCodaEnabled = NO;
                        }
                    }
                }
            }
        }

        if (0 == myMeasureIndex) {
            daCapoEnabled = NO;
            daCapoAlCodaEnabled = NO;
            daCapoAlFineEnabled = NO;
            daCapoAlSegnoEnabled = NO;
        }else {
            NSArray *daCapoJumps = @[
                    @(APJumpTypeDaCapo),
                    @(APJumpTypeDaCapoAlFine),
                    @(APJumpTypeDaCapoAlCoda),
                    @(APJumpTypeDaCapoAlSegno)
            ];
            for (NSNumber *currentJumpTypeNumber in daCapoJumps) {
                APJumpType currentJumpType = [currentJumpTypeNumber intValue];
                
                if (nil != myMeasure.jumpOrigin && currentJumpType != jumpType) {
                    if (APJumpTypeDaCapo == currentJumpType) {
                        daCapoEnabled = NO;
                    }else if (APJumpTypeDaCapoAlFine == currentJumpType) {
                        daCapoAlFineEnabled = NO;
                    }else if (APJumpTypeDaCapoAlCoda == currentJumpType) {
                        daCapoAlCodaEnabled = NO;
                    }else if (APJumpTypeDaCapoAlSegno == currentJumpType) {
                        daCapoAlSegnoEnabled = NO;
                    }
                }else {
                    // Do the core data query only if absolutely necessary
                    Jump *aJump = [scoreManager jumpForScore:self.score andJumpType:currentJumpType];
                    if (nil != aJump.originMeasure && aJump.originMeasure != myMeasure){
                        if (APJumpTypeDaCapo == currentJumpType) {
                            daCapoEnabled = NO;
                        }else if (APJumpTypeDaCapoAlFine == currentJumpType) {
                            daCapoAlFineEnabled = NO;
                        }else if (APJumpTypeDaCapoAlCoda == currentJumpType) {
                            daCapoAlCodaEnabled = NO;
                        }else if (APJumpTypeDaCapoAlSegno == currentJumpType) {
                            daCapoAlSegnoEnabled = NO;
                        }
                    }
                }
            }
        }
    }

    
    self.goToCoda.enabled = goToCodaEnabled;
    self.dalSegno.enabled = dalSegnoEnabled;
    self.dalSegnoAlCoda.enabled = dalSegnoAlCodaEnabled;
    self.dalSegnoAlFine.enabled = dalSegnoAlFineEnabled;
    self.daCapo.enabled = daCapoEnabled;
    self.daCapoAlCoda.enabled = daCapoAlCodaEnabled;
    self.daCapoAlFine.enabled = daCapoAlFineEnabled;
    self.daCapoAlSegno.enabled = daCapoAlSegnoEnabled;
    
    self.dalSegnoTakeRepeats.enabled = (APJumpTypeDalSegno == jumpType);
    self.dalSegnoAlFineTakeRepeats.enabled = (APJumpTypeDalSegnoAlFine == jumpType);
    self.dalSegnoAlCodaTakeRepeats.enabled = (APJumpTypeDalSegnoAlCoda == jumpType);
    self.daCapoTakeRepeats.enabled = (APJumpTypeDaCapo == jumpType);
    self.daCapoAlCodaTakeRepeats.enabled = (APJumpTypeDaCapoAlCoda == jumpType);
    self.daCapoAlFineTakeRepeats.enabled = (APJumpTypeDaCapoAlFine == jumpType);
    self.daCapoAlSegnoTakeRepeats.enabled = (APJumpTypeDaCapoAlSegno == jumpType);
    
    /******************************
     * Set control states
     ******************************/
    // Repeats
    self.startRepeat.on = (nil != myMeasure.startRepeat);
    self.endRepeat.on = (nil != myMeasure.endRepeat);
    self.primaryEnding.on = [myMeasure.primaryEnding boolValue];
    self.secondaryEnding.on = [myMeasure.secondaryEnding boolValue];
    
    if (nil != myMeasure.startRepeat || nil != myMeasure.endRepeat) {
        Repeat *theRepeat = (nil != myMeasure.startRepeat) ? myMeasure.startRepeat : myMeasure.endRepeat;
        [self setSelectedRepeatCountIndex:[theRepeat.numberOfRepeats intValue] -1];
    }else {
        [self setSelectedRepeatCountIndex:0];
    }
    
    // Jump targets
    self.segno.on = [myMeasure.segno boolValue];
    self.coda.on = [myMeasure.coda boolValue];
    self.fine.on = [myMeasure.fine boolValue];
    

    // Jump origins
    self.goToCoda.on = (APJumpTypeGoToCoda == jumpType);
    self.dalSegno.on = (APJumpTypeDalSegno == jumpType);
    self.dalSegnoAlFine.on = (APJumpTypeDalSegnoAlFine == jumpType);
    self.dalSegnoAlCoda.on = (APJumpTypeDalSegnoAlCoda == jumpType);
    self.daCapo.on = (APJumpTypeDaCapo == jumpType);
    self.daCapoAlCoda.on = (APJumpTypeDaCapoAlCoda == jumpType);
    self.daCapoAlFine.on = (APJumpTypeDaCapoAlFine == jumpType);
    self.daCapoAlSegno.on = (APJumpTypeDaCapoAlSegno == jumpType);

    // Set Take repeats checkboxes
    UIImage *checkboxOn = [UIImage imageNamed:@"checkbox_on"];
    UIImage *checkboxOff = [UIImage imageNamed:@"checkbox_off"];
    BOOL takeRepeats = (nil != myMeasure.jumpOrigin && [myMeasure.jumpOrigin.takeRepeats boolValue]);
    UIButton *takeRepeatsButton = nil;
    switch (jumpType) {
        case APJumpTypeDalSegno:
            takeRepeatsButton = self.dalSegnoTakeRepeats;
            break;
        case APJumpTypeDalSegnoAlFine:
            takeRepeatsButton = self.dalSegnoAlFineTakeRepeats;
            break;
        case APJumpTypeDalSegnoAlCoda:
            takeRepeatsButton = self.dalSegnoAlCodaTakeRepeats;
            break;
        case APJumpTypeDaCapo:
            takeRepeatsButton = self.daCapoTakeRepeats;
            break;
        case APJumpTypeDaCapoAlCoda:
            takeRepeatsButton = self.daCapoAlCodaTakeRepeats;
            break;
        case APJumpTypeDaCapoAlFine:
            takeRepeatsButton = self.daCapoAlFineTakeRepeats;
            break;
        case APJumpTypeDaCapoAlSegno:
            takeRepeatsButton = self.daCapoAlSegnoTakeRepeats;
            break;
        case APJumpTypeNone:
            [self.dalSegnoTakeRepeats setImage:checkboxOff forState:UIControlStateNormal];
            [self.dalSegnoAlCodaTakeRepeats setImage:checkboxOff forState:UIControlStateNormal];
            [self.dalSegnoAlFineTakeRepeats setImage:checkboxOff forState:UIControlStateNormal];
            [self.daCapoTakeRepeats setImage:checkboxOff forState:UIControlStateNormal];
            [self.daCapoAlCodaTakeRepeats setImage:checkboxOff forState:UIControlStateNormal];
            [self.daCapoAlFineTakeRepeats setImage:checkboxOff forState:UIControlStateNormal];
            [self.daCapoAlSegnoTakeRepeats setImage:checkboxOff forState:UIControlStateNormal];
            break;
        default:
            takeRepeatsButton = nil;
            break;
    }
    if (nil != takeRepeatsButton) {
        [takeRepeatsButton setImage:takeRepeats ? checkboxOn : checkboxOff 
                           forState:UIControlStateNormal];
    }
    
    
    [self.markerView refreshSymbols];
}


#pragma mark - Repeat changes

- (IBAction)startRepeatChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    
    NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];
    NSInteger myMeasureIndex = [sortedMeasures indexOfObject:self.measure];
    NSArray *nextMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(myMeasureIndex, [sortedMeasures count] - myMeasureIndex)]; // Include self.measure
    
    if (theSwitch.on) {
        // Look for an existing repeat missing a start measure
        for (Measure *nextMeasure in nextMeasures) {
            if (nil != nextMeasure.endRepeat && nil == nextMeasure.endRepeat.startMeasure) {
                nextMeasure.endRepeat.startMeasure = self.measure;
            }
        }
        
        if (nil == self.measure.startRepeat) {
            // Let's go ahead and create that repeat
            Repeat *newRepeat = (Repeat *)[[NSManagedObject alloc] initWithEntity:[Repeat entityDescription]
                                                   insertIntoManagedObjectContext:[[ScoreManager sharedInstance] context_]];
            newRepeat.startMeasure = self.measure;
        }   
    }else {
        Repeat *currentRepeat = self.measure.startRepeat;
        if (nil != currentRepeat) {
            currentRepeat.startMeasure = nil;
            
            NSMutableSet *measures = [[NSMutableSet alloc] init];
            // Remove first endings
            for (Measure *nextMeasure in nextMeasures) {
                [measures addObject:nextMeasure];
                nextMeasure.primaryEnding = [NSNumber numberWithBool:NO];
                if (nil != nextMeasure.startRepeat || nil != nextMeasure.endRepeat) {
                    break;
                }  
            }
            [[self.editorController.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure IN %@", measures]] makeObjectsPerformSelector:@selector(refreshSymbols)];
            
            [[ScoreManager sharedInstance] matchDanglingRepeatsForScore:self.score];
        }                
    }
    [self validateInputAndSyncUI];
}

- (IBAction)endRepeatChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];
    NSInteger myMeasureIndex = [sortedMeasures indexOfObject:self.measure];
    NSArray *previousMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(0, myMeasureIndex + 1)]; // include self.measure
    
    if (theSwitch.on) {    
        // Look for existing repeat that is missing an end measure
        for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
            if (nil != previousMeasure.startRepeat && nil == previousMeasure.startRepeat.endMeasure) {
                Repeat *theRepeat = previousMeasure.startRepeat;
                theRepeat.endMeasure = self.measure;
                break;
            }
        }
    }else {
        Repeat *currentRepeat = self.measure.endRepeat;        
        if (nil != currentRepeat) {
            currentRepeat.endMeasure = nil;
            
            NSMutableSet *measures = [[NSMutableSet alloc] init];
            // Remove primary endings
            for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
                [measures addObject:previousMeasure];
                previousMeasure.primaryEnding = [NSNumber numberWithBool:NO];
                if (nil != previousMeasure.endRepeat || nil != previousMeasure.startRepeat) {
                    break;
                }
            }
            
            // Remove secondary endings
            NSArray *nextMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(myMeasureIndex + 1, [sortedMeasures count] - (myMeasureIndex + 1))]; // Exclude self.measure
            for (Measure *nextMeasure in nextMeasures) {
                [measures addObject:nextMeasure];
                nextMeasure.secondaryEnding = [NSNumber numberWithBool:NO];
                if (nil != nextMeasure.startRepeat || nil != nextMeasure.endRepeat) {
                    break;
                }
            }
            
            [[self.editorController.measureMarkerViews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"measure IN %@", measures]] makeObjectsPerformSelector:@selector(refreshSymbols)];
            
            [[ScoreManager sharedInstance] matchDanglingRepeatsForScore:self.score];
        }
    }
    [self validateInputAndSyncUI];
}

- (IBAction)repeatCountChanged:(id)sender
{
    Repeat *theRepeat = (nil != self.measure.startRepeat) ? self.measure.startRepeat : self.measure.endRepeat;
    if (nil != theRepeat) {
        theRepeat.numberOfRepeats = [NSNumber numberWithInteger:self.numberOfRepeatsSegmentedControl.selectedSegmentIndex + 1];
    }
}

- (IBAction)primaryEndingChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    
    if (theSwitch.on) {
        // Autocomplete primary endings if the repeat block is 'closed'
        NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];
        NSInteger myMeasureIndex = [sortedMeasures indexOfObject:self.measure];
        NSArray *previousMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(0, myMeasureIndex)]; // exclude self.measure
        for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
            if (nil != previousMeasure.startRepeat) { // Placing a primary ending is only allowed with a dangling start repeat
                if (nil != previousMeasure.startRepeat.endMeasure) {
                    Measure * endMeasure = previousMeasure.startRepeat.endMeasure;
                    NSArray *nextMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(myMeasureIndex + 1, [sortedMeasures indexOfObject:endMeasure] - myMeasureIndex)]; // exclude self.measure
                    for (Measure *nextMeasure in nextMeasures) {
                        nextMeasure.primaryEnding = @YES;
                    }
                    // Refresh marker views on the autocompleted measures
                    NSMutableSet *markerViews = [NSMutableSet setWithSet:self.editorController.measureMarkerViews];
                    [markerViews removeObject:self.markerView]; // self.markerview is going to get refreshed in the call to validateInputAndSyncUI
                    [markerViews makeObjectsPerformSelector:@selector(refreshSymbols)];
                }
                break;
            }
        }
        self.measure.primaryEnding = @YES;
    }else {
        self.measure.primaryEnding = @NO;
    }
    [self validateInputAndSyncUI];
}

- (IBAction)secondaryEndingChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    
    if (theSwitch.on) {
        self.measure.secondaryEnding = @YES;
    }else {
        self.measure.secondaryEnding = @NO;
    }
    [self validateInputAndSyncUI];
}

- (IBAction)takeRepeatsChanged:(id)sender
{
    if (nil != self.measure.jumpOrigin) {
        self.measure.jumpOrigin.takeRepeats = [NSNumber numberWithBool:![self.measure.jumpOrigin.takeRepeats boolValue]];        
        [self validateInputAndSyncUI];
    }
}

#pragma mark - Segno changes

- (IBAction)segnoChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;

    NSArray *types = @[
            @(APJumpTypeDalSegno),
            @(APJumpTypeDalSegnoAlCoda),
            @(APJumpTypeDalSegnoAlFine)
    ];
    NSArray *segnoJumps = [[ScoreManager sharedInstance] jumpsForScore:self.score andJumpTypes:types];
    
    if (theSwitch.on) {
        // Add this measure as jumpDestination for all segno jumps
        for (Jump *aJump in segnoJumps) {
            aJump.destinationMeasure = self.measure;
        }
        self.measure.segno = @YES;
    }else {
        // Remove jumpDestination from all segno jumps
        for (Jump *aJump in segnoJumps) {
            if (nil == aJump.originMeasure) {
                [[[ScoreManager sharedInstance] context_] deleteObject:aJump];
            }else {
                aJump.destinationMeasure = nil;
            }
        }
        self.measure.segno = @NO;
    }
#ifdef DEBUG
    NSLog(@"segno jumps: %@", segnoJumps);
#endif
    [self validateInputAndSyncUI];
}

- (IBAction)segnoJumpOriginChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    APJumpType jumpType = theSwitch.tag;
    
    if (theSwitch.on) {
        Measure *segnoMeasure = [[ScoreManager sharedInstance] targetMeasureForScore:self.score andKeyPath:@"segno"];
        Jump *newJump = (Jump *) [[NSManagedObject alloc] initWithEntity:[Jump entityDescription]
                                          insertIntoManagedObjectContext:[[ScoreManager sharedInstance] context_]];
        newJump.jumpType = @(jumpType);
        newJump.destinationMeasure = segnoMeasure; // can be nil
        newJump.originMeasure = self.measure;
    }else {
        Jump *segnoJump = self.measure.jumpOrigin;
        if (nil != segnoJump) {
            [[[ScoreManager sharedInstance] context_] deleteObject:segnoJump];
            self.measure.jumpOrigin = nil;
        }
    }
#ifdef DEBUG
    NSLog(@"segno jump origin: %@", self.measure.jumpOrigin);
#endif
    [self validateInputAndSyncUI];
}

#pragma mark - Fine changes

- (IBAction)fineChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    
    if (theSwitch.on) {
        self.measure.fine = @YES;
    }else {
        self.measure.fine = @NO;
    }
    
    [self validateInputAndSyncUI];
}

#pragma mark - Coda changes

- (IBAction)goToCodaChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    
    ScoreManager *scoreManager = [ScoreManager sharedInstance];
    Jump *codaJump = [scoreManager jumpForScore:self.score 
                                    andJumpType:APJumpTypeGoToCoda];
    
    if (theSwitch.on) {
        if (nil != codaJump) {
            codaJump.originMeasure = self.measure;
        }else {
            codaJump = (Jump *) [[NSManagedObject alloc] initWithEntity:[Jump entityDescription]
                                         insertIntoManagedObjectContext:[scoreManager context_]];
            codaJump.jumpType = @(APJumpTypeGoToCoda);
            codaJump.originMeasure = self.measure;
        }
        if (nil == codaJump.destinationMeasure) {
            // Find existing coda jump targets
            Measure *targetMeasure = [scoreManager targetMeasureForScore:self.score
                                                              andKeyPath:@"coda"];
            if (nil != targetMeasure) {
                codaJump.destinationMeasure = targetMeasure;
            }
        }
    }else {
        if (nil != codaJump) {
            if (nil == codaJump.destinationMeasure) {
                [[scoreManager context_] deleteObject:codaJump];
            }else {
                codaJump.originMeasure = nil;
            }
        }
    }
#ifdef DEBUG
    NSLog(@"coda jump: %@", codaJump);
#endif
    
    [self validateInputAndSyncUI];
}


- (IBAction)codaChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    ScoreManager *scoreManager = [ScoreManager sharedInstance];
    Jump *codaJump = [scoreManager jumpForScore:self.score 
                                    andJumpType:APJumpTypeGoToCoda];

    if (theSwitch.on) {
        if (nil != codaJump) {
            codaJump.destinationMeasure = self.measure;
        }else {
            codaJump = (Jump *) [[NSManagedObject alloc] initWithEntity:[Jump entityDescription]
                                            insertIntoManagedObjectContext:[scoreManager context_]];
            codaJump.jumpType = @(APJumpTypeGoToCoda);
            codaJump.destinationMeasure = self.measure;
        }        
        self.measure.coda = @YES;
    }else {
        if (nil != codaJump) {
            if (nil == codaJump.originMeasure) {
                [[scoreManager context_] deleteObject:codaJump];
            }else {
                codaJump.destinationMeasure = nil;
            }
        }
        self.measure.coda = @NO;
    }
    
#ifdef DEBUG
    NSLog(@"coda jump: %@", codaJump);
#endif
    [self validateInputAndSyncUI];
}


#pragma mark - DaCapo jump origin changes
- (IBAction)daCapoJumpOriginChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    
    APJumpType jumpType = theSwitch.tag;
    
    if (theSwitch.on) {
        NSArray *sortedMeasures = [self.score measuresSortedByCoordinates];
        Measure *daCapoMeasure = [sortedMeasures count] > 0 ? [sortedMeasures objectAtIndex:0] : nil;
        Jump *newJump = (Jump *) [[NSManagedObject alloc] initWithEntity:[Jump entityDescription]
                                          insertIntoManagedObjectContext:[[ScoreManager sharedInstance] context_]];
        newJump.jumpType = @(jumpType);
        newJump.destinationMeasure = daCapoMeasure;
        newJump.originMeasure = self.measure;
    }else {
        Jump *daCapoJumpOrigin = self.measure.jumpOrigin;
        if (nil != daCapoJumpOrigin) {
            [[[ScoreManager sharedInstance] context_] deleteObject:daCapoJumpOrigin];
            self.measure.jumpOrigin = nil;
        }
    }
#ifdef DEBUG
    NSLog(@"daCapo jump origin: %@", self.measure.jumpOrigin);
#endif

    [self validateInputAndSyncUI];
}

#pragma mark - Utilities


- (void)setSelectedRepeatCountIndex:(NSInteger)count
{
    // Bug in UISegmentedControl sends action message on programmatic index changes
    // Solution: temporarily disable action
    [self.numberOfRepeatsSegmentedControl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
    self.numberOfRepeatsSegmentedControl.selectedSegmentIndex = count;
    [self.numberOfRepeatsSegmentedControl addTarget:self action:@selector(repeatCountChanged:) forControlEvents:UIControlEventValueChanged];
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
                                                           inView:self.scrollView
                                         permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                                         animated:YES];
        }];
        self.bpmHelpPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.bpmHelpPopoverController.delegate = self;
        [controller loadContent];
    }    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController { // Is not called in response to programatic dismissal
    if ([popoverController isEqual:self.bpmHelpPopoverController]) {
        self.bpmHelpPopoverController.delegate = nil;
        self.bpmHelpPopoverController = nil;
    }
}

- (IBAction)showBpmPicker:(id)sender {
    [ActionSheetCustomPicker showPickerWithTitle:nil
                                        delegate:self
                                showCancelButton:NO
                                          origin:sender
                               initialSelections:@[
                                       @([self.bpmValues indexOfObject:self.measure.bpm])
                               ]];
}

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker
      configurePickerView:(UIPickerView *)pickerView
{
    ;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    ;
}

- (void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    ;
}


@end
