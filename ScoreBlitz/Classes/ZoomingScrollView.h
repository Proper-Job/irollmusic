//
//  ZoomingScrollView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 15.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Page;
@class ImageTilingView;


@interface ZoomingScrollView : UIScrollView <UIScrollViewDelegate> {

}
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) Page *page;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) ImageTilingView *tilingView;

- (void)invalidate;
- (void)willDisplay;

@end
