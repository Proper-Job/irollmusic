//
//  ScrollSpeedSelectorViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 07.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScrollSpeedSelectorViewController : UIViewController {
    NSInteger _scrollSpeed;
}

@property (nonatomic, strong) IBOutlet UILabel *speedLevelLabel, *speedLabel;
@property (nonatomic, strong) IBOutlet UIButton *upButton, *downButton;
@property (nonatomic, strong) Score *score;

- (void)becomeOpaque;
- (void)becomeTransparent;

- (IBAction)downTapped;
- (IBAction)upTapped;

#define kScrollSpeedSelectorHideAfterDuration 4.0
#define kFadeAnimationDuration .125
#define kScrollSpeedSelectorAlpha .4

@end

