//
//  RecentScoreList.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentScoreList.h"
#import "ScoreBlitzAppDelegate.h"
#import "RecentScoreListEntry.h"

@implementation RecentScoreList

@dynamic recentScoreListEntries;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"RecentScoreList" inManagedObjectContext:context];
}

- (NSArray *)orderedRecentScoreListEntriesAsc
{
	NSArray *arrayWithSortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES selector:@selector(compare:)]];
	//NSArray *orderedSetListEntriesAsc = 
	return [self.recentScoreListEntries sortedArrayUsingDescriptors:arrayWithSortDescriptor];
	
	//return [[orderedSetListEntriesAsc retain] autorelease];
}

@end
