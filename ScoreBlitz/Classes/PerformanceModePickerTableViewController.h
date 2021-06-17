//
//  PerformanceModePickerTableViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PerformanceModePickerTableViewController : UITableViewController

@property (nonatomic, copy) void (^modePickedCompletion)(PerformanceMode newMode);
@property (nonatomic, strong) NSArray *performanceModes;
@property (nonatomic, assign) PerformanceMode performanceMode;

- (id)initWithPerformanceMode:(PerformanceMode)theMode
         modePickedCompletion:(void(^)(PerformanceMode newMode))modePickedCompletion;

@end


