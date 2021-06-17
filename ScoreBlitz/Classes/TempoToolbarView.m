//
//  TempoToolbarView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TempoToolbarView.h"


@implementation TempoToolbarView

- (IBAction)tap {
    if (self.didReceiveTouchBlock) {
        self.didReceiveTouchBlock(self);
    }
}


@end
