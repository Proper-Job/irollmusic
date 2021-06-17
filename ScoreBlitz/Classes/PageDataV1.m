//
//  pageDataV1.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageDataV1.h"
#import "ScoreDataV1.h"

@implementation PageDataV1

@synthesize number, score, measures, drawAnnotationsData, textAnnotationsData;

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
    
    number = [aDecoder decodeObjectForKey:@"number"];
    score = [aDecoder decodeObjectForKey:@"score"];
    measures = [aDecoder decodeObjectForKey:@"measures"];
    drawAnnotationsData = [aDecoder decodeObjectForKey:@"drawAnnotationsData"];
    textAnnotationsData = [aDecoder decodeObjectForKey:@"textAnnotationsData"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.number forKey:@"number"];
    [aCoder encodeObject:self.score forKey:@"score"];
    [aCoder encodeObject:self.measures forKey:@"measures"];
    [aCoder encodeObject:self.drawAnnotationsData forKey:@"drawAnnotationsData"];
    [aCoder encodeObject:self.textAnnotationsData forKey:@"textAnnotationsData"];
}

- (NSArray *)measuresSortedByCoordinates
{
    NSSortDescriptor *xCoordinateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"xCoordinate" ascending:YES];
    NSSortDescriptor *yCoordinateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"yCoordinate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:yCoordinateDescriptor, xCoordinateDescriptor, nil];
    return [self.measures sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark -
#pragma mark Memory Management

@end
