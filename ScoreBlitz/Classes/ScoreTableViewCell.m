//
//  ScoreTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import "ScoreTableViewCell.h"
#import "Score.h"

@implementation ScoreTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.scoreTitleLabel.textColor = [UIColor blackColor];
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    
    UIView *bg = [[UIView alloc] initWithFrame:self.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bg.backgroundColor = [Helpers petrol];
    self.selectedBackgroundView = bg;
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.scoreTitleLabel.textColor = [UIColor whiteColor];
        [self.playButton setImage:[UIImage imageNamed:@"play_white"] forState:UIControlStateNormal];
    } else {
        self.scoreTitleLabel.textColor = [UIColor blackColor];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)setupWithScore:(Score*)score
{
    self.scoreTitleLabel.text = score.name;
}

@end
