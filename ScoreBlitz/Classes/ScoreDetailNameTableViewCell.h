//
//  ScoreDetailNameTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreDetailNameTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;

- (void)setupWithScore:(Score*)score;

@end
