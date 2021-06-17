//
//  AnnotationPen.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnotationPen.h"


@implementation AnnotationPen

@synthesize color, lineWidth, alpha;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    color = [aDecoder decodeObjectForKey:@"color"];
    lineWidth = [aDecoder decodeObjectForKey:@"lineWidth"];
    alpha = [aDecoder decodeObjectForKey:@"alpha"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:self.lineWidth forKey:@"lineWidth"];
    [aCoder encodeObject:self.alpha forKey:@"alpha"];
}



@end
