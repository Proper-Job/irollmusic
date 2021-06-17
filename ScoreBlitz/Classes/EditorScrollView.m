//
//  EditorScrollView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditorScrollView.h"

@implementation EditorScrollView


- (void)layoutSubviews
{
    [super layoutSubviews];

    UIView *previewImageView = [self viewWithTag:kEditorPreviewImageViewTag];
    if (nil != previewImageView) {
        CGSize boundsSize = self.bounds.size;
        CGRect frameToCenter = previewImageView.frame;

        // center horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = roundf((boundsSize.width - frameToCenter.size.width) / 2.0f);
        } else {
            frameToCenter.origin.x = 0;
        }

        // center vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = roundf((boundsSize.height - frameToCenter.size.height) / 2.0f);
        } else {
            frameToCenter.origin.y = 0;
        }

        previewImageView.frame = frameToCenter;
    }
}

@end
