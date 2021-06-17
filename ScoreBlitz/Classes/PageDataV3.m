//
//  PageDataV3.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageDataV3.h"
#import "ScoreDataV3.h"

@implementation PageDataV3

@synthesize number, score, measures, drawAnnotationsData, textAnnotationsData, signAnnotationsData;

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
    signAnnotationsData = [aDecoder decodeObjectForKey:@"signAnnotationsData"];    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.number forKey:@"number"];
    [aCoder encodeObject:self.score forKey:@"score"];
    [aCoder encodeObject:self.measures forKey:@"measures"];
    [aCoder encodeObject:self.drawAnnotationsData forKey:@"drawAnnotationsData"];
    [aCoder encodeObject:self.textAnnotationsData forKey:@"textAnnotationsData"];
    [aCoder encodeObject:self.signAnnotationsData forKey:@"signAnnotationsData"];    
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