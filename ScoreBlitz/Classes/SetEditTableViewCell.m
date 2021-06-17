//
//  SetEditTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import "SetEditTableViewCell.h"
#import "Score.h"

@implementation SetEditTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.scoreTitleLabel.textColor = [UIColor blackColor];
    self.playtimeLabel.textColor = [UIColor blackColor];
    self.addScoreButton.tintColor = [Helpers petrol];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.scoreTitleLabel.textColor = [UIColor whiteColor];
        self.playtimeLabel.textColor = [UIColor whiteColor];
        self.addScoreButton.tintColor = [UIColor whiteColor];
    } else {
        self.scoreTitleLabel.textColor = [UIColor blackColor];
        self.playtimeLabel.textColor = [UIColor blackColor];
        self.addScoreButton.tintColor = [Helpers petrol];
    }
}

- (void)setupWithScore:(Score*)score
{
    self.scoreTitleLabel.text = score.name;
    self.playtimeLabel.text = [score playTimeString];
}

@end
