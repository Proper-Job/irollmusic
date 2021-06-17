//
//  ScoreDetailPreviewTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreDetailPreviewTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UIButton *rotationButton;

- (void)setupWithScore:(Score*)score;

@end
