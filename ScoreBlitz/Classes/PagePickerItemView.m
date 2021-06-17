//
//  PagePickerItemView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PagePickerItemView.h"
#import "PagePickerScrollView.h"
#import "Page.h"

@implementation PagePickerItemView

- (IBAction)pagePickerButtonPressed
{
    [self.pickerScrollView pagePickerButtonPressedWithPage:self.page];
}



@end
