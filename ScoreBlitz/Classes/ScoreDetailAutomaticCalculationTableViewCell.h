//
//  ScoreDetailAutomaticCalculationTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreDetailAutomaticCalculationTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *automaticCalculationLabel;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) IBOutlet UISwitch *automaticCalculationSwitch;

- (void)setupWithScore:(Score*)score;

@end
