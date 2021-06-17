//
//  SetDetailTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import <UIKit/UIKit.h>

@class SetListEntry;

@interface SetDetailTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *scoreTitleLabel, *playtimeLabel;

- (void)setupWithSetListEntry:(SetListEntry*)setListentry;

@end
