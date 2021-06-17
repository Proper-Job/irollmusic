//
//  ScoreDetailGenreTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import "ScoreDetailGenreTableViewCell.h"
#import "Score.h"
#import "Helpers.h"

@implementation ScoreDetailGenreTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [Helpers lightGrey];
    
    self.genreLabel.textColor = [Helpers grey];
    self.genreTextField.textColor = [UIColor blackColor];

    self.genreLabel.text = MyLocalizedString(@"scoreDetailGenreLabel", nil);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithScore:(Score*)score
{
    self.genreTextField.text = score.genre;
}

@end
