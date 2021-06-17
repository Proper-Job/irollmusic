//
//  Repeat.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 26.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Repeat.h"
#import "ScoreBlitzAppDelegate.h"

@implementation Repeat

@dynamic numberOfRepeats;
@dynamic endMeasure;
@dynamic startMeasure;


+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"Repeat" inManagedObjectContext:context];
}

@end
