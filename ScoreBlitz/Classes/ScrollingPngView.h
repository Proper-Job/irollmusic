//
//  PerformancePngView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 19.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Page;
@class ImageTilingView;


@interface ScrollingPngView : UIView

@property (nonatomic, strong) Page *page;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) ImageTilingView *tilingView;

- (void)invalidate;
- (void)willDisplay;
@end
