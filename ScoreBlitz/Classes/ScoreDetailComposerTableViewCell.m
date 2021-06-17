//
//  ScoreDetailComposerTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import "ScoreDetailComposerTableViewCell.h"
#import "Score.h"
#import "Helpers.h"

@implementation ScoreDetailComposerTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [Helpers lightGrey];
    
    self.composerLabel.textColor = [Helpers grey];
    self.composerTextField.textColor = [UIColor blackColor];

    self.composerLabel.text = MyLocalizedString(@"scoreDetailComposerLabel", nil);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithScore:(Score*)score
{
    self.composerTextField.text = score.composer;
}

@end
