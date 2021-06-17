//
//  ScoreActionItemTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import <UIKit/UIKit.h>

@class ScoreActionItem;

@interface ScoreActionItemTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL didSetupConstraints;

- (void)updateFonts;
- (void)setupWithScoreActionItem:(ScoreActionItem*)scoreActionItem;

@end
