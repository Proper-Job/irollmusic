//
//  RecentSetListEntry.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentSetListEntry.h"
#import "ScoreBlitzAppDelegate.h"

@implementation RecentSetListEntry

@dynamic rank, recentSetList, setList;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"RecentSetListEntry" inManagedObjectContext:context];
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
