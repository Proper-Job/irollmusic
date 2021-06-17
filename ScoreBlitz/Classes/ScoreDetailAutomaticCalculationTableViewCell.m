//
//  ScoreDetailAutomaticCalculationTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import "ScoreDetailAutomaticCalculationTableViewCell.h"
#import "Score.h"
#import "Helpers.h"

@implementation ScoreDetailAutomaticCalculationTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [Helpers lightGrey];
    
    self.automaticCalculationLabel.textColor = [Helpers grey];
    self.automaticCalculationLabel.text = MyLocalizedString(@"scoreDetailAutomaticCalculationLabel", nil);
    
    self.infoButton.tintColor = [Helpers petrol];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithScore:(Score*)score
{
    self.automaticCalculationSwitch.on = [score.automaticPlayTimeCalculation boolValue];
}

@end
