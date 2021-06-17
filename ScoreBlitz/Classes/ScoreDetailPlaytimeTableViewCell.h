//
//  ScoreDetailPlaytimeTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreDetailPlaytimeTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *playtimeLabel, *timeLabel;
@property (nonatomic, strong) IBOutlet UIButton *playtimeButton;

- (void)setupWithScore:(Score*)score;

@end
