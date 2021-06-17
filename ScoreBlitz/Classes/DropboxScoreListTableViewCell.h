//
//  DropboxScoreListTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface DropboxScoreListTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *scoreNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *addButton;

- (void)setupWithScore:(Score*)score;

@end
