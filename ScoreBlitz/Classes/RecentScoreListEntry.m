//
//  RecentScoreListEntry.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentScoreListEntry.h"
#import "ScoreBlitzAppDelegate.h"
#import "RecentScoreList.h"
#import "Score.h"

@implementation RecentScoreListEntry

@dynamic rank, recentScoreList, score;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"RecentScoreListEntry" inManagedObjectContext:context];
}

- (void)decRank
{
	self.rank = [NSNumber numberWithInt:[self.rank intValue] -1];
}

- (void)incRank
{
	self.rank = [NSNumber numberWithInt:[self.rank intValue] +1];
}


@end
