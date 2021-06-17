//
//  HelpViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@class HelpViewController;
@class BrowserViewController;

@protocol HelpViewControllerDelegate <NSObject>

- (void)helpViewControllerDidDissmissHelpView:(HelpViewController *)helpViewController;

@end

@interface HelpViewController : UIViewController <UIPopoverControllerDelegate, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIButton *tutorialButton, *doneButton;
@property (nonatomic, strong) IBOutlet UIView *centerHelpView, *leftTapZoneView, *rightTapZoneView;
@property (nonatomic, strong) IBOutlet UILabel *leftTapZoneLabel, *rightTapZoneLabel;
@property (nonatomic, strong) NSString *windowTitle, *mainTemplate;
@property (nonatomic, strong) UIPopoverController *popOverViewController;
@property (nonatomic, strong) NSMutableArray *controlItems, *helpDescriptions, *targetsAndSelectorsOfControlItems, *templates;
@property (nonatomic, assign) NSInteger helpViewControllerType;
@property (nonatomic, copy) NSString *mainHelpDescription;
@property (nonatomic, assign) TutorialType tutorialType;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayerViewController;
@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) void (^completion)(void);

- (id)initWithControlItems:(NSArray *)items
          templates:(NSArray *)templates
       mainTemplate:(NSString *)mainTemplate
              tutorialType:(TutorialType)theType
                  completion:(void(^)(void))completion;

- (void)dissmissHelpViewController;

- (IBAction)tutorialButtonTapped;
- (IBAction)doneButtonTapped;

- (void)addHelpToControls;
- (void)buttonTapped:(UIControl *)button withEvent:(UIEvent *)event;

#define kTargetKey @"target"
#define kSelectorKey @"selector"
#define kHelpViewControllerFadeAnimationDuration .35


@end

