//
//  SetCollectionViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 13.05.14.
//
//

#import "SetCollectionViewCell.h"
#import "RecentSetListEntry.h"
#import "Set.h"
#import "Score.h"
#import "SetListEntry.h"

@implementation SetCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.setBackgroundView.backgroundColor = [Helpers darkYellow];
    
    UIColor *labelTextColor = [Helpers black];
    self.label0.textColor = labelTextColor;
    self.label1.textColor = labelTextColor;
    self.label2.textColor = labelTextColor;
    self.label3.textColor = labelTextColor;
    self.label4.textColor = labelTextColor;
    self.label5.textColor = labelTextColor;
    self.label6.textColor = labelTextColor;
    self.label7.textColor = labelTextColor;
    self.label8.textColor = labelTextColor;
    
    self.titleLabel.textColor = [Helpers darkYellow];
}


- (void)setupWithRecentSetListEntry:(RecentSetListEntry*)recentSetListEntry
{
    self.titleLabel.text = recentSetListEntry.setList.name;
    
    // write setListEntries on preview
    NSArray *setListEntries = [recentSetListEntry.setList orderedSetListEntriesAsc];
    
    for (SetListEntry *setListEntry in setListEntries)
	{
		if ([setListEntries indexOfObject:setListEntry] < (8)) {
            NSInteger index = [setListEntries indexOfObject:setListEntry];
			UILabel *label = [self valueForKey:[NSString stringWithFormat:@"label%ld", (long)index]];
			label.text = [NSString stringWithFormat:@"%ld. %@", index + 1, setListEntry.score.name];
		}
	}
}

@end
