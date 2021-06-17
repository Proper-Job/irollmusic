    //
//  SettingsViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import "SettingsViewController.h"
#import "CentralViewController.h"
#import "SettingsManager.h"
#import "TrackingManager.h"
#import "APCheckedLabel.h"
#import "APCheckedImage.h"


@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged) name:kLanguageChanged object:nil];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[Helpers doneBarButtonItemWithTarget:self action:@selector(done)]];
    
    self.view.backgroundColor = [Helpers lightGrey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.helpersSwitch.on = [defaults boolForKey:kShowHelpers];
    self.continuousSimpleScrollSwitch.on = [defaults boolForKey:kSettingSimpleModeScrollsContinuously];
    self.enableTapZonesSwitch.on = [defaults boolForKey:kSettingEnablePagingTapZones];
    self.rollByMeasureShowArrowSwitch.on = [defaults boolForKey:kSettingRollByMeasureShowArrow];
    self.flashPageNumberSwitch.on = [defaults boolForKey:kSettingPagingTapZoneFlashPageNumber]; 
    if (!self.enableTapZonesSwitch.on) {
        self.flashPageNumberSwitch.enabled = NO;
    }
    
    // Configure switches
    self.continuousSimpleScrollSwitch.tag = SettingSimpleModeContinuousScroll;
    self.enableTapZonesSwitch.tag = SettingSwitchEnableTapZones;
    self.helpersSwitch.tag = SettingSwitchShowLibraryHelpers;
    self.flashPageNumberSwitch.tag = SettingSwitchFlashPagingPageNumber;
    self.rollByMeasureShowArrowSwitch.tag = SettingSwitchShowArrow;
    
    self.hostingScrollView.contentSize = CGSizeMake(self.view.frameWidth, 640.0);
    
    // Configure Labels
    UIFont *font = [Helpers avenirNextCondensedDemiBoldFontWithSize:14.0];
    UIImage *checkImage = [UIImage imageNamed:@"check"];
    UIColor *textColor = [Helpers petrol];
    PerformanceScrollPosition performanceScrollPosition = (int)[defaults integerForKey:kSettingScrollPosition];
    
    self.autoCheckedLabel.font = font;
    self.autoCheckedLabel.textColor = textColor;
    self.autoCheckedLabel.checkImage = checkImage;

    self.topCheckedLabel.font = font;
    self.topCheckedLabel.textColor = textColor;
    self.topCheckedLabel.checkImage = checkImage;

    self.middleCheckedLabel.font = font;
    self.middleCheckedLabel.textColor = textColor;
    self.middleCheckedLabel.checkImage = checkImage;

    self.bottomCheckedLabel.font = font;
    self.bottomCheckedLabel.textColor = textColor;
    self.bottomCheckedLabel.checkImage = checkImage;

    switch (performanceScrollPosition) {
        case PerformanceScrollPositionTop: {
            [self.topCheckedLabel setChecked:YES];
            break;
        }

        case PerformanceScrollPositionMiddle: {
            [self.middleCheckedLabel setChecked:YES];
            break;
        }

        case PerformanceScrollPositionBottom: {
            [self.bottomCheckedLabel setChecked:YES];
            break;
        }
            
        default: { // PerformanceScrollPositionAutomatic
            [self.autoCheckedLabel setChecked:YES];
            break;
        }
    }
    
    // Configure CheckedImages
    self.germanCheckedImage.image = [UIImage imageNamed:@"settings_german"];
    self.germanCheckedImage.checkImage = checkImage;
    
    self.englishCheckedImage.image = [UIImage imageNamed:@"settings_english"];
    self.englishCheckedImage.checkImage = checkImage;
    
    self.frenchCheckedImage.image = [UIImage imageNamed:@"settings_french"];
    self.frenchCheckedImage.checkImage = checkImage;
    
    self.spanishCheckedImage.image = [UIImage imageNamed:@"settings_spanish"];
    self.spanishCheckedImage.checkImage = checkImage;
    
    self.chineseSimpleCheckedImage.image = [UIImage imageNamed:@"settings_chinese"];
    self.chineseSimpleCheckedImage.checkImage = checkImage;
    
    NSString *language= [SettingsManager language];
    
    if ([language isEqualToString:kGermanLanguage]) {
        [self.germanCheckedImage setChecked:YES];
    } else if ([language isEqualToString:kEnglishLanguage]) {
        [self.englishCheckedImage setChecked:YES];
    } else if ([language isEqualToString:kFrenchLanguage]) {
        [self.frenchCheckedImage setChecked:YES];
    } else if ([language isEqualToString:kSpanishLanguage]) {
        [self.spanishCheckedImage setChecked:YES];
    } else if ([language isEqualToString:kChineseSimplifiedLanguage]) {
        [self.chineseSimpleCheckedImage setChecked:YES];
    }
    
    [self languageChanged];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[TrackingManager sharedInstance] trackGoogleViewWithIdentifier:[NSString stringWithFormat:@"%@", [self class]]];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWillAnimateRotationToInterfaceOrientation                                                        object:self];
}

- (void)languageChanged
{
    [self.navigationItem setTitle:MyLocalizedString(@"centralViewSettingsbutton", nil)];
    
    self.continuousSimpleScrollLabel.text = MyLocalizedString(@"simpleModeScrollsContinuously", nil);
    self.showHelpersLabel.text = MyLocalizedString(@"showHelpers", nil);
    self.enableTapZonesLabel.text = MyLocalizedString(@"settingEnablePagingTapZones", nil);
    self.flashPageNumberLabel.text = MyLocalizedString(@"settingFlashPagingPageIndicator", nil);
    self.scrollPositionLabel.text = MyLocalizedString(@"settingsScrollPositions", nil);
    self.rollByMeasureShowArrowLabel.text = MyLocalizedString(@"settingRollByMeasureShowArrow", nil);

    // Headings
    self.simpleModeHeadingLabel.text = MyLocalizedString(@"simplePerformanceMode", nil);
    self.pagingModeHeadingLabel.text = MyLocalizedString(@"pagingPerformanceMode", nil);
    self.libraryHeadingLabel.text = MyLocalizedString(@"centralViewLibraryButton", nil);
    self.generalHeadingLabel.text = MyLocalizedString(@"settingsHeadingGeneralSettings", nil);
    self.advancedModeHeadingLabel.text = MyLocalizedString(@"advancedPerformanceMode", nil);
    
    // CheckedLabels
    [self.autoCheckedLabel setTitle:MyLocalizedString(@"settingsScrollPositionAutomatic", nil)];
    [self.topCheckedLabel setTitle:MyLocalizedString(@"settingsScrollPositionTop", nil)];
    [self.middleCheckedLabel setTitle:MyLocalizedString(@"settingsScrollPositionMiddle", nil)];
    [self.bottomCheckedLabel setTitle:MyLocalizedString(@"settingsScrollPositionBottom", nil)];
}


#pragma mark -
#pragma mark Button actions


- (IBAction)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchToggled:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    switch (theSwitch.tag) {
        case SettingSimpleModeContinuousScroll:
            [defaults setBool:theSwitch.on forKey:kSettingSimpleModeScrollsContinuously];
            break;
        case SettingSwitchShowLibraryHelpers:
            [defaults setBool:theSwitch.on forKey:kShowHelpers];
            break;
        case SettingSwitchEnableTapZones:
            [defaults setBool:theSwitch.on forKey:kSettingEnablePagingTapZones];
            if (theSwitch.on) {
                self.flashPageNumberSwitch.enabled = YES;
            }else {
                self.flashPageNumberSwitch.enabled = NO;
            }
            break;
        case SettingSwitchFlashPagingPageNumber:
            [defaults setBool:theSwitch.on forKey:kSettingPagingTapZoneFlashPageNumber];
            break;
        case SettingSwitchShowArrow:
            [defaults setBool:theSwitch.on forKey:kSettingRollByMeasureShowArrow];
            break;
    }
}

- (IBAction)checkLabelToggeled:(id)sender
{
    APCheckedLabel *checkedLabel = (APCheckedLabel*)sender;
    
    if (checkedLabel.isChecked) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([checkedLabel isEqual:self.autoCheckedLabel]) {
            [self.topCheckedLabel setChecked:NO];
            [self.middleCheckedLabel setChecked:NO];
            [self.bottomCheckedLabel setChecked:NO];
            [defaults setInteger:PerformanceScrollPositionAutomatic forKey:kSettingScrollPosition];
        } else if ([checkedLabel isEqual:self.topCheckedLabel]) {
            [self.autoCheckedLabel setChecked:NO];
            [self.middleCheckedLabel setChecked:NO];
            [self.bottomCheckedLabel setChecked:NO];
            [defaults setInteger:PerformanceScrollPositionTop forKey:kSettingScrollPosition];
        } else if ([checkedLabel isEqual:self.middleCheckedLabel]) {
            [self.autoCheckedLabel setChecked:NO];
            [self.topCheckedLabel setChecked:NO];
            [self.bottomCheckedLabel setChecked:NO];
            [defaults setInteger:PerformanceScrollPositionMiddle forKey:kSettingScrollPosition];
        } else if ([checkedLabel isEqual:self.bottomCheckedLabel]) {
            [self.autoCheckedLabel setChecked:NO];
            [self.topCheckedLabel setChecked:NO];
            [self.middleCheckedLabel setChecked:NO];
            [defaults setInteger:PerformanceScrollPositionBottom forKey:kSettingScrollPosition];
        }
    } else {
        [checkedLabel setChecked:YES];
    }
}

- (IBAction)checkImageToggle:(id)sender
{
    APCheckedImage *checkImage = (APCheckedImage*)sender;
    
    if (checkImage.isChecked) {
        if ([checkImage isEqual:self.germanCheckedImage]) {
            [self.englishCheckedImage setChecked:NO];
            [self.frenchCheckedImage setChecked:NO];
            [self.spanishCheckedImage setChecked:NO];
            [self.chineseSimpleCheckedImage setChecked:NO];
            [SettingsManager setLanguage:kGermanLanguage];
        } else if ([checkImage isEqual:self.englishCheckedImage]) {
            [self.germanCheckedImage setChecked:NO];
            [self.frenchCheckedImage setChecked:NO];
            [self.spanishCheckedImage setChecked:NO];
            [self.chineseSimpleCheckedImage setChecked:NO];
            [SettingsManager setLanguage:kEnglishLanguage];
        } else if ([checkImage isEqual:self.frenchCheckedImage]) {
            [self.germanCheckedImage setChecked:NO];
            [self.englishCheckedImage setChecked:NO];
            [self.spanishCheckedImage setChecked:NO];
            [self.chineseSimpleCheckedImage setChecked:NO];
             [SettingsManager setLanguage:kFrenchLanguage];
        } else if ([checkImage isEqual:self.spanishCheckedImage]) {
            [self.germanCheckedImage setChecked:NO];
            [self.englishCheckedImage setChecked:NO];
            [self.frenchCheckedImage setChecked:NO];
            [self.chineseSimpleCheckedImage setChecked:NO];
            [SettingsManager setLanguage:kSpanishLanguage];
        } else if ([checkImage isEqual:self.chineseSimpleCheckedImage]) {
            [self.germanCheckedImage setChecked:NO];
            [self.englishCheckedImage setChecked:NO];
            [self.frenchCheckedImage setChecked:NO];
            [self.spanishCheckedImage setChecked:NO];
            [SettingsManager setLanguage:kChineseSimplifiedLanguage];
        }
    } else {
        [checkImage setChecked:YES];
    }    
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
