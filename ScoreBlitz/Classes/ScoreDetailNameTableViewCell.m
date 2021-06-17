//
//  ScoreDetailNameTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import "ScoreDetailNameTableViewCell.h"
#import "Score.h"
#import "Helpers.h"

@implementation ScoreDetailNameTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [Helpers lightGrey];
    
    self.nameLabel.textColor = [Helpers grey];
    self.nameTextField.textColor = [UIColor blackColor];

    self.nameLabel.text = MyLocalizedString(@"scoreDetailNameLabel", nil);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithScore:(Score*)score
{
    self.nameTextField.text = score.name;
}

@end
