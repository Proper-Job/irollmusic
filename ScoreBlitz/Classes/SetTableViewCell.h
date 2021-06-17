//
//  SetTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import <UIKit/UIKit.h>

@class Set;

@interface SetTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *setTitleLabel, *playtimeLabel;
@property (nonatomic, strong) IBOutlet UIButton *playButton;

- (void)setupWithSet:(Set*)set;

@end
