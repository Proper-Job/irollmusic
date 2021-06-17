//
//  SetCollectionViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 13.05.14.
//
//

#import <UIKit/UIKit.h>

@class RecentSetListEntry;

@interface SetCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIView *setBackgroundView;
@property (nonatomic, strong) IBOutlet UILabel *label0, *label1, *label2, *label3, *label4, *label5, *label6, *label7, *label8;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

- (void)setupWithRecentSetListEntry:(RecentSetListEntry*)recentSetListEntry;

@end
