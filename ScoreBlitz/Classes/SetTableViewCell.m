//
//  SetTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import "SetTableViewCell.h"
#import "Set.h"

@implementation SetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *bg = [[UIView alloc] initWithFrame:self.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bg.backgroundColor = [Helpers petrol];
    self.selectedBackgroundView = bg;
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.setTitleLabel.textColor = [UIColor whiteColor];
        self.playtimeLabel.textColor = [UIColor whiteColor];
        [self.playButton setImage:[UIImage imageNamed:@"play_white"] forState:UIControlStateNormal];
    } else {
        self.setTitleLabel.textColor = [UIColor blackColor];
        self.playtimeLabel.textColor = [UIColor blackColor];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)setupWithSet:(Set*)set
{
    self.setTitleLabel.text = set.name;
    self.playtimeLabel.text = [set playTimeString];
}

@end
