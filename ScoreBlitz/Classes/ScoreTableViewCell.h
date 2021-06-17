//
//  ScoreTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *scoreTitleLabel;
@property (nonatomic, strong) IBOutlet UIButton *playButton;

- (void)setupWithScore:(Score*)score;

@end
