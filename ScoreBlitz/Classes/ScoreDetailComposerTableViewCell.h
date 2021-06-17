//
//  ScoreDetailComposerTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreDetailComposerTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *composerLabel;
@property (nonatomic, strong) IBOutlet UITextField *composerTextField;

- (void)setupWithScore:(Score*)score;

@end
