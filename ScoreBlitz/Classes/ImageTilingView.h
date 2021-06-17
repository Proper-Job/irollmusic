//
//  ImageTilingView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 06.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PerformanceAnnotationView;
@class Page;

@interface ImageTilingView : UIView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) PerformanceAnnotationView *annotationView;
@property (nonatomic, strong) Page *page;

- (void)invalidate;
- (void)willDisplay;

@end