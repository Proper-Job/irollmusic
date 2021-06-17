//
//  ScorePickerTableViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 01.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Set;
@class PerformanceViewController;
@class ScorePickerTableViewCell;
@class RoundedGradientButton;

@interface ScorePickerTableViewController : UITableViewController

@property (nonatomic, strong) Set *setList;
@property (nonatomic, copy) void (^completion)(NSInteger scoreIndex);
@property (nonatomic, assign) NSInteger activeScoreIndex;

- (id)initWithSet:(Set *)setList
 activeScoreIndex:(NSInteger)activeScoreIndex
       completion:(void(^)(NSInteger index))completion;
@end
