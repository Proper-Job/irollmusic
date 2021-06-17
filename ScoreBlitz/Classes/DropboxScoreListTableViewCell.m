//
//  DropboxScoreListTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import "DropboxScoreListTableViewCell.h"
#import "Score.h"

@implementation DropboxScoreListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.scoreNameLabel.textColor = [UIColor blackColor];
    self.addButton.tintColor = [Helpers petrol];    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.scoreNameLabel.textColor = [UIColor whiteColor];
        self.addButton.tintColor = [UIColor whiteColor];
    } else {
        self.scoreNameLabel.textColor = [UIColor blackColor];
        self.addButton.tintColor = [Helpers petrol];
    }

}

- (void)setupWithScore:(Score*)score
{
    self.scoreNameLabel.text = score.name;
}

@end
