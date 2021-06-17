//
//  MeasureDataV2.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MeasureDataV2.h"
#import "PageDataV2.h"
#import "RepeatDataV2.h"
#import "JumpDataV2.h"

@implementation MeasureDataV2

@synthesize coordinateAsString, bpm, coda, fine, segno, primaryEnding, secondaryEnding, timeDenominator, timeNumerator;
@synthesize startRepeat, endRepeat, jumpDestinations, jumpOrigin, page;

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
    
    coordinateAsString = [aDecoder decodeObjectForKey:@"coordinateAsString"];
    bpm = [aDecoder decodeObjectForKey:@"bpm"];
    coda = [aDecoder decodeObjectForKey:@"coda"];
    fine = [aDecoder decodeObjectForKey:@"fine"];
    segno = [aDecoder decodeObjectForKey:@"segno"];
    primaryEnding = [aDecoder decodeObjectForKey:@"primaryEnding"];
    secondaryEnding = [aDecoder decodeObjectForKey:@"secondaryEnding"];
    timeDenominator = [aDecoder decodeObjectForKey:@"timeDenominator"];
    timeNumerator = [aDecoder decodeObjectForKey:@"timeNumerator"];
    startRepeat = [aDecoder decodeObjectForKey:@"startRepeat"];
    endRepeat = [aDecoder decodeObjectForKey:@"endRepeat"];
    jumpDestinations = [aDecoder decodeObjectForKey:@"jumpDestinations"];
    jumpOrigin = [aDecoder decodeObjectForKey:@"jumpOrigin"];
    page = [aDecoder decodeObjectForKey:@"page"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.coordinateAsString forKey:@"coordinateAsString"];
    [aCoder encodeObject:self.bpm forKey:@"bpm"];
    [aCoder encodeObject:self.coda forKey:@"coda"];
    [aCoder encodeObject:self.fine forKey:@"fine"];
    [aCoder encodeObject:self.segno forKey:@"segno"];
    [aCoder encodeObject:self.primaryEnding forKey:@"primaryEnding"];
    [aCoder encodeObject:self.secondaryEnding forKey:@"secondaryEnding"];
    [aCoder encodeObject:self.timeDenominator forKey:@"timeDenominator"];
    [aCoder encodeObject:self.timeNumerator forKey:@"timeNumerator"];
    [aCoder encodeObject:self.startRepeat forKey:@"startRepeat"];
    [aCoder encodeObject:self.endRepeat forKey:@"endRepeat"];
    [aCoder encodeObject:self.jumpDestinations forKey:@"jumpDestinations"];
    [aCoder encodeObject:self.jumpOrigin forKey:@"jumpOrigin"];
    [aCoder encodeObject:self.page forKey:@"page"];
}

- (NSNumber *)xCoordinate
{
    CGPoint point = CGPointFromString(self.coordinateAsString);
    return [NSNumber numberWithFloat:point.x];
}

- (NSNumber *)yCoordinate
{
    CGPoint point = CGPointFromString(self.coordinateAsString);
    return [NSNumber numberWithFloat:point.y];
}

#pragma mark -
#pragma mark Memory Management

@end
