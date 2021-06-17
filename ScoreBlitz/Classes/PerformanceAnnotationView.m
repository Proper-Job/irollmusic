//
//  PerformanceAnnotationView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 17.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerformanceAnnotationView.h"
#import "Page.h"
#import "SignAnnotation.h"
#import "PrintSignAnnotation.h"

@implementation PerformanceAnnotationView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        ;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSDictionary *annotations = [self.page annotationsDictionaryForFrameSize:self.bounds.size invertY:NO];
    
    NSArray *bezierPaths = [annotations valueForKey:kAnnotationBezierPaths];
    NSArray *colorsForBezierPaths = [annotations valueForKey:kAnnotationBezierPathColors];
    NSArray *alphaForBezierPaths = [annotations valueForKey:kAnnotationBezierPathAlpha];
    
    NSArray *strings = [annotations valueForKey:kAnnotationStrings];
    NSArray *pointsForStrings = [annotations valueForKey:kAnnotationStringPoints];
    NSArray *fontNameForStrings = [annotations valueForKey:kAnnotationFontName];
    NSArray *fontSizeForStrings = [annotations valueForKey:kAnnotationFontSize];
    
    for (UIBezierPath *bezierPath in bezierPaths) {
        NSUInteger index = [bezierPaths indexOfObject:bezierPath];
        [colorsForBezierPaths[index] setStroke];
        [bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:[alphaForBezierPaths[index] floatValue]];
    }
    
    for (NSString *string in strings) {
        NSUInteger index = [strings indexOfObject:string];
        CGFloat size = UIFont.systemFontSize;
        if (index < fontSizeForStrings.count) {
            size = [fontSizeForStrings[index] floatValue];
        }
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
        [string drawAtPoint:[pointsForStrings[index] CGPointValue] withAttributes:attributes];
    }
    
    // draw signAnnotations in context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    NSArray *signAnnotations = [self.page signAnnotationsForFrameSize:self.bounds.size];
    for (SignAnnotation *signAnnotation in signAnnotations) {
        CGContextSaveGState(currentContext);
        CGContextTranslateCTM(
                currentContext,
                signAnnotation.caLayer.frame.origin.x,
                signAnnotation.caLayer.frame.origin.y
        );
        PrintSignAnnotation *printSignAnnotation = [[PrintSignAnnotation alloc] initWithFrame:signAnnotation.caLayer.frame];
        printSignAnnotation.svgDocument = signAnnotation.svgDocument;
        printSignAnnotation.color = signAnnotation.color;                
        [printSignAnnotation renderAsVectorInContext:currentContext];
        CGContextRestoreGState(currentContext);
    }
}


@end
