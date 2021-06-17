//
//  TapTempoInputButton.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TapTempoInputButton.h"


@interface TapTempoInputButton ()
@property (nonatomic, strong) NSDate *tap1, *tap2, *tap3;
@end


@implementation TapTempoInputButton

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchDown];
        
        self.clipsToBounds = YES;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIImage *buttonBackgroundImage = [Helpers imageFromColor:[Helpers petrol]];
        UIImage *highlightedImage = [Helpers imageFromColor:[Helpers black]];
        [self setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    return self;
}

- (IBAction)tap
{
    NSDate *currentTap = [NSDate date];
    if (nil != self.tap1 && nil != self.tap2 && nil != self.tap3) {
        NSInteger bpm = (NSInteger)round(
                60.0 / (([self.tap2 timeIntervalSinceDate:self.tap1] + [self.tap3 timeIntervalSinceDate:self.tap2]
                        + [currentTap timeIntervalSinceDate:self.tap3])
                        / 3.0)
        );

        if (bpm < 40 || bpm > 208) {
            self.tap1 = nil;
            self.tap2 = nil;
            self.tap3 = nil;
            return;
        }
        NSNumber *match = @(bpm);

        if (nil != match && self.didSelectBpmBlock) {
            self.didSelectBpmBlock(match);
        }
    }
    self.tap1 = self.tap2;
    self.tap2 = self.tap3;
    self.tap3 = currentTap;
}


@end
