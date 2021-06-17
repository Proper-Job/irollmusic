//
//  AnnotationsBezierPath.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawAnnotation.h"


@implementation DrawAnnotation

@synthesize bezierPath, color;
@synthesize relativePointsOfBezierPath, alpha, lineWidth;
@synthesize originalFrame;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    color = [aDecoder decodeObjectForKey:@"color"];
    alpha = [aDecoder decodeObjectForKey:@"alpha"];
    lineWidth = [aDecoder decodeObjectForKey:@"lineWidth"];
    relativePointsOfBezierPath = [aDecoder decodeObjectForKey:@"relativePointsOfBezierPath"];
    originalFrame = [aDecoder decodeObjectForKey:@"originalFrame"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:self.alpha forKey:@"alpha"];
    [aCoder encodeObject:self.lineWidth forKey:@"lineWidth"];
    [aCoder encodeObject:self.relativePointsOfBezierPath forKey:@"relativePointsOfBezierPath"];    
    [aCoder encodeObject:self.originalFrame forKey:@"originalFrame"]; 
}

void DrawSignAnnotationPathApplierFunc (void *info, const CGPathElement *element)
{
    NSMutableArray *arrayOfPoints = (__bridge NSMutableArray *)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type)
    {
        case kCGPathElementMoveToPoint: // contains 1 point
            [arrayOfPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
            
        case kCGPathElementAddLineToPoint: // contains 1 point
            [arrayOfPoints addObject:[NSValue valueWithCGPoint:points[0]]];            
            break;
            
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            [arrayOfPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [arrayOfPoints addObject:[NSValue valueWithCGPoint:points[1]]];            
            break;
            
        case kCGPathElementAddCurveToPoint: // contains 3 points
            [arrayOfPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [arrayOfPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [arrayOfPoints addObject:[NSValue valueWithCGPoint:points[2]]];
            break;
            
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}

- (NSArray *)pointsOfBezierPath
{
    NSMutableArray *points = [NSMutableArray array];
    
    CGPathApply(self.bezierPath.CGPath, (__bridge void *)(points), DrawSignAnnotationPathApplierFunc);
    return points;
}

- (void)createRelativePointsOfBezierPath
{
    CGSize size;
    
    if (nil == self.originalFrame) {
#ifdef DEBUG        
        [NSException raise:@"Cannot create RelativePointsOfBezierPath" format:@"Set originalFrame first!"];
#endif
    } else {
        size = [self.originalFrame CGRectValue].size;
    }
    
    NSMutableArray *tmpRelativePoints = [NSMutableArray array];
    NSArray *points = [self pointsOfBezierPath];
    for (NSValue *pointValue in points) {
        CGPoint point = [pointValue CGPointValue];
        point.x = point.x / size.width;
        point.y = point.y / size.height;
        [tmpRelativePoints addObject:[NSValue valueWithCGPoint:point]];
#ifdef DEBUG        
        if ((point.x > 1) || (point.x < 0)|| (point.y > 1) || (point.y < 0)) {
            NSLog(@"Wrong pointOfBezierPath: %@", NSStringFromCGPoint(point));
        }
#endif
    }
    self.relativePointsOfBezierPath = tmpRelativePoints;
    

}

- (void)adjustLineWithOfBezierPathWithSize:(CGSize)newSize
{
    CGSize originalSize = [self.originalFrame CGRectValue].size;
    
    CGFloat scale = newSize.width / originalSize.width;
    
    self.bezierPath.lineWidth = [self.lineWidth floatValue] * scale;
}

- (CGFloat)relativeLineWidthForSize:(CGSize)newSize
{
    CGSize originalSize = [self.originalFrame CGRectValue].size;
    
    CGFloat scale = newSize.width / originalSize.width;
    
    return ([self.lineWidth floatValue] * scale);
}



@end
