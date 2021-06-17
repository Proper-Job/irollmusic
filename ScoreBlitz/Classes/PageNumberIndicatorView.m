//
//  PageNumberIndicatorView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageNumberIndicatorView.h"


@implementation PageNumberIndicatorView

@synthesize topImageView, bottomImageView, pageNumberLabel, pageNumberBackgroundView, tapZonePagePosition;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pageNumberBackgroundView.layer.cornerRadius = roundf(self.pageNumberBackgroundView.frameWidth / 2.0f);
}

- (void)showPageNumber:(NSInteger)number
                inView:(UIView *)theSuperView 
        positionInView:(PageNumberIndicatorPosition)positionInView
   tapZonePagePosition:(TapZonePagePosition)newTapZonePosition
{
    self.pageNumberLabel.text = [NSString stringWithFormat:@"%d", number];
    self.tapZonePagePosition = newTapZonePosition;
    
    self.center = theSuperView.center;
    
    switch (positionInView) {
        case PageNumberIndicatorPositionLeft:
            self.frameX = 0;
            break;
        case PageNumberIndicatorPositionRight:
            self.frameX = theSuperView.frameWidth - self.frameWidth;
            break;
        case PageNumberIndicatorPositionCenter:
            break;
        default:
            break;
    }
    
    self.frameOrigin = CGPointMake(roundf(self.frameX), roundf(self.frameY));
    
    self.alpha = 1.0;
    if (![self.superview isEqual:theSuperView]) {
        [theSuperView addSubview:self];  
    }
    [UIView animateWithDuration:kFadeOutDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         ;
                     }];
}

- (void)setTapZonePagePosition:(TapZonePagePosition)newPosition
{
    tapZonePagePosition = newPosition;
    
    switch (tapZonePagePosition) {
        case TapZonePagePositionTop:
            self.topImageView.hidden = NO;
            self.bottomImageView.hidden = YES;
            break;
        case TapZonePagePositionBottom:
            self.topImageView.hidden = YES;
            self.bottomImageView.hidden = NO;
            break;
        case TapZonePagePositionNone:
            self.topImageView.hidden = YES;
            self.bottomImageView.hidden = YES;
            break;
        default:
            break;
    }
}




@end
