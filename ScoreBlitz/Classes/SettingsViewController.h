//
//  SettingsViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CentralViewController, APCheckedLabel, APCheckedImage;

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIScrollView *hostingScrollView;
@property (nonatomic, strong) IBOutlet UILabel *continuousSimpleScrollLabel, *showHelpersLabel, *enableTapZonesLabel, *flashPageNumberLabel, *scrollPositionLabel, *rollByMeasureShowArrowLabel;
@property (nonatomic, strong) IBOutlet UISwitch *continuousSimpleScrollSwitch, *enableTapZonesSwitch, *helpersSwitch, *flashPageNumberSwitch, *rollByMeasureShowArrowSwitch;
@property (nonatomic, strong) IBOutlet UILabel *simpleModeHeadingLabel, *pagingModeHeadingLabel, *libraryHeadingLabel, *languageHeadingLabel, *generalHeadingLabel, *advancedModeHeadingLabel;
@property (nonatomic, strong) IBOutlet APCheckedLabel *autoCheckedLabel, *topCheckedLabel, *middleCheckedLabel, *bottomCheckedLabel;
@property (nonatomic, strong) IBOutlet APCheckedImage *germanCheckedImage, *englishCheckedImage, *frenchCheckedImage, *spanishCheckedImage, *chineseSimpleCheckedImage;

- (IBAction)done;
- (IBAction)switchToggled:(id)sender;

- (void)languageChanged;

typedef enum {
    SettingSimpleModeContinuousScroll = 8674,
    SettingSwitchEnableTapZones,
    SettingSwitchShowLibraryHelpers,
    SettingSwitchFlashPagingPageNumber,
    SettingSwitchShowArrow
} SettingSwitch;

@end
