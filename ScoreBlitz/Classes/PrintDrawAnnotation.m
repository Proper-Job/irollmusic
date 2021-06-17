//
//  PrintDrawAnnotation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PrintDrawAnnotation.h"

@implementation PrintDrawAnnotation


@synthesize paths, colors, alphas;
@synthesize rect;


-(void)renderAsVectorInContext:(CGContextRef)context
{
    [super renderAsVectorInContext:context];
    
    for (UIBezierPath *bezierPath in self.paths) {
        NSInteger index = [self.paths indexOfObject:bezierPath];
        UIColor *color = [self.colors objectAtIndex:index];
        
        // draw the path into context
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextSetLineWidth(context, bezierPath.lineWidth);   
        CGContextSetStrokeColorWithColor(context, color.CGColor);        
        CGContextSetAlpha(context, [[self.alphas objectAtIndex:index] floatValue]);
        if ([color isEqual:[UIColor clearColor]]) {
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            CGContextDrawPath(context, kCGPathFillStroke);                        
        } else {


            CGContextSetBlendMode(context, kCGBlendModeCopy);
            CGContextDrawPath(context, kCGPathStroke);            
        }
        
        
        
    }
        
}

@end
