//
//  ScoreDetailGenreTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreDetailGenreTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *genreLabel;
@property (nonatomic, strong) IBOutlet UITextField *genreTextField;

- (void)setupWithScore:(Score*)score;

@end
