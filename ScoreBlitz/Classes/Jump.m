//
//  Jump.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 28.04.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Jump.h"
#import "Measure.h"
#import "ScoreBlitzAppDelegate.h"

@implementation Jump

@dynamic jumpType;
@dynamic takeRepeats;
@dynamic originMeasure;
@dynamic destinationMeasure;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"Jump" inManagedObjectContext:context];
}

@end
