//
//  SetDetailTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import "SetDetailTableViewCell.h"
#import "SetListEntry.h"
#import "Score.h"

@implementation SetDetailTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithSetListEntry:(SetListEntry*)setListentry
{
    self.scoreTitleLabel.text = setListentry.score.name;
    self.playtimeLabel.text = [setListentry.score playTimeString];
}

@end
