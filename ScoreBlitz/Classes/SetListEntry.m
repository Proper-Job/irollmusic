//
//  SetListEntry.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 08.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetListEntry.h"
#import "ScoreBlitzAppDelegate.h"

@implementation SetListEntry

@dynamic rank, score, setList;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"SetListEntry" inManagedObjectContext:context];
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
