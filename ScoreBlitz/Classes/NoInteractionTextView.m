//
//  NoInteractionTextView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoInteractionTextView.h"


@implementation NoInteractionTextView

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{    
    [UIMenuController sharedMenuController].menuVisible = NO;
    return NO;    
}

@end
