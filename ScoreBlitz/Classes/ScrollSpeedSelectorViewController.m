//
//  ScrollSpeedSelectorViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 07.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollSpeedSelectorViewController.h"
#import "Score.h"

@implementation ScrollSpeedSelectorViewController

@synthesize speedLevelLabel, speedLabel, upButton, downButton;
@synthesize score;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _scrollSpeed = 10;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.speedLabel.text = MyLocalizedString(@"simpleScrollSpeedSelectorSpeedLabel", nil);
    self.speedLevelLabel.text = [NSString stringWithFormat:@"%d", _scrollSpeed];
    
    [self performSelector:@selector(becomeTransparent)
               withObject:nil
               afterDelay:kScrollSpeedSelectorHideAfterDuration]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.speedLevelLabel = nil;
    self.upButton = nil;
    self.downButton = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(becomeTransparent)
                                               object:nil];
}


#pragma mark - Button actions

- (IBAction)downTapped
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(becomeTransparent)
                                               object:nil];
    [self becomeOpaque];
    
    if (_scrollSpeed > 1) {
        _scrollSpeed--;
        self.speedLevelLabel.text = [NSString stringWithFormat:@"%d", _scrollSpeed];
        self.score.scrollSpeed = [NSNumber numberWithInt:_scrollSpeed];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kSimpleScrollSpeedDidChangeNotification
                                                                                             object:nil]];
    }
    
    [self performSelector:@selector(becomeTransparent)
               withObject:nil
               afterDelay:kScrollSpeedSelectorHideAfterDuration];
}

- (IBAction)upTapped
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(becomeTransparent)
                                               object:nil];
    [self becomeOpaque];
    
    if (_scrollSpeed < 20) {
        _scrollSpeed++;
        self.speedLevelLabel.text = [NSString stringWithFormat:@"%d", _scrollSpeed];
        self.score.scrollSpeed = [NSNumber numberWithInt:_scrollSpeed];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kSimpleScrollSpeedDidChangeNotification
                                                                                             object:nil]];
    }
    
    [self performSelector:@selector(becomeTransparent)
               withObject:nil
               afterDelay:kScrollSpeedSelectorHideAfterDuration];

}


#pragma mark - Appearance

- (void)becomeOpaque
{
    [UIView animateWithDuration:kFadeAnimationDuration
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         self.view.alpha = 1.0;  
                     }completion:^(BOOL finished) {
                         ;
                     }];
}

- (void)becomeTransparent
{
    [UIView animateWithDuration:kFadeAnimationDuration
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         self.view.alpha = kScrollSpeedSelectorAlpha;
                     }completion:^(BOOL finished) {
                         ;
                     }];    
}


- (void)setScore:(Score *)theScore
{
    if (score != theScore) {
        score = theScore;
        
        _scrollSpeed = [score.scrollSpeed intValue];
        self.speedLevelLabel.text = [NSString stringWithFormat:@"%d", _scrollSpeed];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kSimpleScrollSpeedDidChangeNotification
                                                                                             object:nil]];
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(becomeTransparent)
                                               object:nil];
    
}


@end
