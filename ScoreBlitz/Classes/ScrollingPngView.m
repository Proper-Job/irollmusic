//
//  PerformancePngView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 19.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import "ScrollingPngView.h"
#import "Page.h"
#import "ImageTilingView.h"



@implementation ScrollingPngView

@synthesize page, index;
@synthesize tilingView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor whiteColor];

		tilingView = [[ImageTilingView alloc] initWithFrame:CGRectZero];
        [self addSubview:tilingView];
        [self bringSubviewToFront:tilingView];

    }
    return self;
}

- (id)init {
	return [self initWithFrame:CGRectZero];
}

- (void)invalidate
{
    self.page = nil;
    self.layer.contents = nil;
    [self.tilingView invalidate];
}

- (void)willDisplay
{
    self.layer.contents = (__bridge id)[[self.page previewImage] CGImage];
    [self.tilingView willDisplay];
}

#pragma mark -
#pragma mark Layout


- (void)layoutSubviews
{
	[super layoutSubviews];
	// to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
	// tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
	// which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
	self.tilingView.contentScaleFactor = 1.0;
}


#pragma mark -
#pragma mark Memory Management



@end
