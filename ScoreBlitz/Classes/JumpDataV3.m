//
//  JumpDataV3.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JumpDataV3.h"
#import "MeasureDataV3.h"

@implementation JumpDataV3

@synthesize jumpType, takeRepeats, originMeasure, destinationMeasure;

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
    
    jumpType = [aDecoder decodeObjectForKey:@"jumpType"];
    takeRepeats = [aDecoder decodeObjectForKey:@"takeRepeats"];
    originMeasure = [aDecoder decodeObjectForKey:@"originMeasure"];
    destinationMeasure = [aDecoder decodeObjectForKey:@"destinationMeasure"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.jumpType forKey:@"jumpType"];
    [aCoder encodeObject:self.takeRepeats forKey:@"takeRepeats"];
    [aCoder encodeObject:self.originMeasure forKey:@"originMeasure"];
    [aCoder encodeObject:self.destinationMeasure forKey:@"destinationMeasure"];
}
#pragma mark -
#pragma mark Memory Management

@end
