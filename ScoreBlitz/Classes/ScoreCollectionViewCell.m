//
//  ScoreCollectionViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 13.05.14.
//
//

#import "ScoreCollectionViewCell.h"
#import "RecentScoreListEntry.h"
#import "Score.h"
#import "Page.h"

@implementation ScoreCollectionViewCell

- (void)setupWithRecentScoreListEntry:(RecentScoreListEntry*)recentScoreListEntry
{
    self.previewImageView.image =  [[[recentScoreListEntry.score orderedPagesAsc] objectAtIndex:0] previewImageSmall];
    self.titleLabel.text = recentScoreListEntry.score.name;
}

@end
