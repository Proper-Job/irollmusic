//
//  ToggleToolbarInfoView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ToggleToolbarInfoView.h"

@implementation ToggleToolbarInfoView

@synthesize infoLabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

@end
