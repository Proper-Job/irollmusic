//
//  RecentSetList.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentSetList.h"
#import "ScoreBlitzAppDelegate.h"

@implementation RecentSetList

@dynamic recentSetListEntries;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"RecentSetList" inManagedObjectContext:context];
}

- (NSArray *)orderedRecentSetListEntriesAsc
{
	NSArray *arrayWithSortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES selector:@selector(compare:)]];
	NSArray *orderedSetListEntriesAsc = [NSArray arrayWithArray:[self.recentSetListEntries sortedArrayUsingDescriptors:arrayWithSortDescriptor]];
	
	return orderedSetListEntriesAsc;
}


@end
