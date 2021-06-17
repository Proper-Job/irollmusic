//
//  ScoreCollectionViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 13.05.14.
//
//

#import <UIKit/UIKit.h>

@class RecentScoreListEntry;

@interface ScoreCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

- (void)setupWithRecentScoreListEntry:(RecentScoreListEntry*)recentScoreListEntry;

@end
