//
//  JumpDataV2.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JumpDataV2.h"
#import "MeasureDataV2.h"

@implementation JumpDataV2

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
