//
//  MySegmentedControl.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MySegmentedControl.h"
#import "HelpViewController.h"

@implementation MySegmentedControl

@synthesize helpController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (nil != self.helpController && [self.helpController respondsToSelector:@selector(buttonTapped:withEvent:)]) {
        [self.helpController buttonTapped:self withEvent:nil];
        return;
    }else {
        [super touchesBegan:touches withEvent:event];
    }
}
@end
