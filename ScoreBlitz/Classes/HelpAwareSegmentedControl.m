//
//  HelpAwareSegmentedControl.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpAwareSegmentedControl.h"
#import "HelpViewController.h"

@implementation HelpAwareSegmentedControl

@synthesize helpController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (nil != self.helpController && 
        [self.helpController respondsToSelector:@selector(buttonTapped:withEvent:)]) 
    {
        [self.helpController buttonTapped:self withEvent:nil];
        return;
    }else {
        [super touchesBegan:touches withEvent:event];
    }
}

@end
