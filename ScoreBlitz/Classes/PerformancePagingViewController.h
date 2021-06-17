//
//  PerformancePageViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerformanceViewController.h"

@class PageNumberIndicatorView;
@class PerformanceScrollingViewController;

@interface PerformancePagingViewController : PerformanceViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet PageNumberIndicatorView *pageNumberView;
@property (nonatomic, weak) PerformanceScrollingViewController *scrollingViewController;
@property (nonatomic, assign) BOOL canvasDidSetup;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *performanceScrollViewLeftConstraint, *performanceScrollViewRightConstraint;
@property (nonatomic, strong) UIBarButtonItem *previousPageItem, *nextPageItem;

- (id)initWithSet:(Set *)theSet
            score:(Score *)theScore
             page:(Page *)thePage;

- (IBAction)previousPage;
- (IBAction)nextPage;


#define kOffsetRequiringScrollingPortrait 100.0f
#define kOffsetRequiringScrollingLandscape 60.0f
#define kEnablePagePositionThreshold 200.0f

@end
