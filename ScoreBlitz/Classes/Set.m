//
//  Set.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 03.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Set.h"
#import "SetListEntry.h"
#import "Score.h"
#import "ScoreBlitzAppDelegate.h"

@implementation Set

@dynamic name, setListEntries;

- (void)awakeFromInsert {
    [super awakeFromInsert];
	self.name = [NSString string];
}

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"Set" inManagedObjectContext:context];
}


- (NSArray *)orderedSetListEntriesAsc
{
	NSArray *arrayWithSortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES selector:@selector(compare:)]];
	NSArray *orderedSetListEntriesAsc = [NSArray arrayWithArray:[self.setListEntries sortedArrayUsingDescriptors:arrayWithSortDescriptor]];
	
	return orderedSetListEntriesAsc;
}

- (NSInteger)playTime
{
   NSInteger playTime = 0;
   
   for (SetListEntry *setListEntry in self.setListEntries){
      playTime += [setListEntry.score.playTime intValue];
   }
   return playTime;
}

- (NSString *)playTimeString
{
    NSInteger playTime = 0;
    BOOL scoresWithoutPlayTime = NO;
    
   for (SetListEntry *setListEntry in self.setListEntries){
       NSInteger playTimeOfScore = [setListEntry.score.playTime intValue];
       if (playTimeOfScore == 0){
           scoresWithoutPlayTime = YES;
       } else {
           playTime += playTimeOfScore;
       }
   }
    
    NSInteger minutes = playTime / 60;
    NSInteger seconds = playTime % 60;  
    
    NSString *playTimeString = [MyLocalizedString(@"tableViewCellPlayTime", nil) stringByAppendingString:@": "];
        
    if (playTime == 0) {
        playTimeString = [playTimeString stringByAppendingString:MyLocalizedString(@"tableViewCellPlayTimeNotAvailableString", nil)];
    } else {
        playTimeString = [playTimeString stringByAppendingFormat:@"%d:%02d", minutes, seconds];
    }
    
    if (scoresWithoutPlayTime && !(playTime == 0)) {
        playTimeString = [playTimeString stringByAppendingString:@" +"];
    }
    
    return playTimeString;
}

- (NSArray*)unAnalyzedScores
{
    NSArray *unAnalyzedScores = [NSArray array];
    if ([self.setListEntries count] > 0) {
        NSSet *uniqueScores = [self.setListEntries valueForKeyPath:@"@distinctUnionOfObjects.score"];
        unAnalyzedScores = [NSArray arrayWithArray:[[uniqueScores filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isAnalyzed == FALSE"]] allObjects]];
    }
    return unAnalyzedScores;
}

@end
