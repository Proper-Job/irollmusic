//
//  CountInView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CountInView.h"


@implementation CountInView

@synthesize countInLabel;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        self.layer.cornerRadius = 8;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
