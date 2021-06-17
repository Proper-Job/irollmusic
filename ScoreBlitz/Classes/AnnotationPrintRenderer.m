//
//  AnnotationPrintRenderer.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnnotationPrintRenderer.h"
#import "Page.h"
#import "SignAnnotation.h"
#import "PrintSignAnnotation.h"
#import "PrintDrawAnnotation.h"


@implementation AnnotationPrintRenderer

// nice idea , but doesn't work because eraser (clear color) doesn't x-out the colored stuff any more

+ (void)renderAnnotationsForPage:(Page*)page inContext:(CGContextRef)context forContextSize:(CGSize)contextSize
{
    @autoreleasepool {
        
        NSDictionary *annotations = [page annotationsDictionaryForFrameSize:contextSize invertY:NO];
        
        NSArray *bezierPaths = [annotations valueForKey:kAnnotationBezierPaths];
        NSArray *colorsForBezierPaths = [annotations valueForKey:kAnnotationBezierPathColors];
        NSArray *alphaForBezierPaths = [annotations valueForKey:kAnnotationBezierPathAlpha];
        
        
        NSArray *strings = [annotations valueForKey:kAnnotationStrings];
        NSArray *pointsForStrings = [annotations valueForKey:kAnnotationStringPoints];
        NSArray *fontNameForStrings = [annotations valueForKey:kAnnotationFontName];
        NSArray *fontSizeForStrings = [annotations valueForKey:kAnnotationFontSize];
        

        PrintDrawAnnotation *printDrawAnnotation = [[PrintDrawAnnotation alloc] initWithFrame:CGRectMake(0, 0, contextSize.width, contextSize.height)];
        printDrawAnnotation.paths = bezierPaths;
        printDrawAnnotation.colors = colorsForBezierPaths;
        printDrawAnnotation.alphas = alphaForBezierPaths;
        printDrawAnnotation.rect = CGRectMake(0, 0, contextSize.width, contextSize.height);
        
        [printDrawAnnotation renderAsVectorInContext:context];

        
        for (NSString *string in strings) {
            NSInteger index = [strings indexOfObject:string];
            CGPoint point = [[pointsForStrings objectAtIndex:index] CGPointValue];
            
            CGFloat size = UIFont.systemFontSize;
            if (index < fontSizeForStrings.count) {
                size = [fontSizeForStrings[index] floatValue];
            }
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
            [string drawAtPoint:point withAttributes:attributes];
        }
        
        // draw signAnnotations in context
        NSArray *signAnnotations = [page signAnnotationsForFrameSize:contextSize];
        for (SignAnnotation *signAnnotation in signAnnotations) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, signAnnotation.caLayer.frame.origin.x, signAnnotation.caLayer.frame.origin.y);
            PrintSignAnnotation *printSignAnnotation = [[PrintSignAnnotation alloc] initWithFrame:signAnnotation.caLayer.frame];
            printSignAnnotation.svgDocument = signAnnotation.svgDocument;
            printSignAnnotation.color = signAnnotation.color;                
            [printSignAnnotation renderAsVectorInContext:context];     
            CGContextRestoreGState(context);
        }
    
    }
    
}


@end
