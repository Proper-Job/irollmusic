//
//  SetEditTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface SetEditTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *scoreTitleLabel, *playtimeLabel;
@property (nonatomic, strong) IBOutlet UIButton *addScoreButton;

- (void)setupWithScore:(Score*)score;

@end
