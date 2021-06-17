//
//  ZoomingScrollView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 15.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "ZoomingScrollView.h"
#import "ImageTilingView.h"
#import "Page.h"
#import "ScoreManager.h"
#import "ALView+PureLayout.h"

@interface ZoomingScrollView ()

@end

@implementation ZoomingScrollView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 1.5;
        self.bouncesZoom = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        self.bounces = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;

        self.backgroundImageView = [[UIImageView alloc] init];
        self.backgroundImageView.backgroundColor = [UIColor clearColor];
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.backgroundImageView];

        
        self.tilingView = [[ImageTilingView alloc] initWithFrame:frame];
        self.tilingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.tilingView];
        [self bringSubviewToFront:self.tilingView];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)invalidate
{
    self.backgroundImageView.image = nil;
    self.page = nil;
    self.zoomScale = 1.0;
    
    [self.tilingView invalidate];
}

- (void)willDisplay
{
    self.backgroundImageView.frameSize = self.frameSize;
    self.backgroundImageView.image = [self.page previewImage];
    [self.tilingView willDisplay];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	// center the subview as it becomes smaller than the size of the screen

    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.tilingView.frame;
    self.tilingView.contentScaleFactor = 1.0;

    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = roundf((boundsSize.width - frameToCenter.size.width) / 2.0f);
    }else {
        frameToCenter.origin.x = 0;
    }

    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = roundf((boundsSize.height - frameToCenter.size.height) / 2.0f);
    }else {
        frameToCenter.origin.y = 0;
    }

    self.tilingView.frame = frameToCenter;
	self.backgroundImageView.frame = frameToCenter;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.tilingView;
    
}

@end
