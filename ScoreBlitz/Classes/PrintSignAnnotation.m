//
//  PrintSignAnnotation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PrintSignAnnotation.h"
#import "SVGKit.h"

@implementation PrintSignAnnotation

@synthesize svgDocument;
@synthesize color;


-(void)renderAsVectorInContext:(CGContextRef)context
{
    [super renderAsVectorInContext:context];
    
    CGSize layerSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    
    NSArray *svgShapeElements = [self.svgDocument svgShapeElements];
    CGSize svgDocumentSize = CGSizeMake(svgDocument.width, svgDocument.height);
    
    for (SVGShapeElement *shapeElement in svgShapeElements) {        
        // scale the path accordingly to the context change
        CGFloat scaleX = layerSize.width / svgDocumentSize.width;
        CGFloat scaleY = layerSize.height / svgDocumentSize.height;
        CGAffineTransform pathTransform = CGAffineTransformMakeScale(scaleX, scaleY);
        
        //CGPathRef convertedPath = [self convertPath:shapeElement.path FromSize:svgDocumentSize toSize:contextSize];
        CGPathRef convertedPath = CGPathCreateCopyByTransformingPath(shapeElement.path, &pathTransform);
        
        // draw the path into context
        CGContextAddPath(context, convertedPath);
        CGContextSetLineWidth(context, shapeElement.strokeWidth);   
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetAlpha(context, shapeElement.opacity);
        
        CGContextDrawPath(context, kCGPathStroke);
        
        if (shapeElement.fillType == SVGFillTypeSolid) {
            CGContextAddPath(context, convertedPath);
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            
            CGContextDrawPath(context, kCGPathFill);
        }
        
        CGPathRelease(convertedPath);
    }
}


@end
