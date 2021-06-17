//
//  ScoreDetailPlaytimeTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import "ScoreDetailPlaytimeTableViewCell.h"
#import "Score.h"
#import "Helpers.h"

@implementation ScoreDetailPlaytimeTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [Helpers lightGrey];
    
    self.playtimeLabel.textColor = [Helpers grey];
    self.timeLabel.textColor = [UIColor blackColor];

    self.playtimeLabel.text = MyLocalizedString(@"scoreDetailPlaytimeLabel", nil);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithScore:(Score*)score
{
    self.timeLabel.text = [score playTimeString];
}

@end
