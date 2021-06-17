//
//  RepeatDataV3.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RepeatDataV3.h"
#import "MeasureDataV3.h"

@implementation RepeatDataV3

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
