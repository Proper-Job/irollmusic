//
//  repeatDataV1.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepeatDataV1.h"
#import "MeasureDataV1.h"

@implementation RepeatDataV1

@synthesize numberOfRepeats, endMeasure, startMeasure;

- (id)init
{
	self = [super init];
	if (self != nil) {
        
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    numberOfRepeats = [aDecoder decodeObjectForKey:@"numberOfRepeats"];
    endMeasure = [aDecoder decodeObjectForKey:@"endMeasure"];
    startMeasure = [aDecoder decodeObjectForKey:@"startMeasure"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.numberOfRepeats forKey:@"numberOfRepeats"];
    [aCoder encodeObject:self.endMeasure forKey:@"endMeasure"];
    [aCoder encodeObject:self.startMeasure forKey:@"startMeasure"];
}
#pragma mark -
#pragma mark Memory Management

@end
