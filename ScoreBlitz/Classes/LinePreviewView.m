//
//  LinePreviewView.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 28.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LinePreviewView.h"
#import "DrawAnnotation.h"
#import "AnnotationPen.h"


@implementation LinePreviewView

@synthesize annotation, annotations, pen;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        annotations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // draw the saved paths
    if ([self.annotations count] > 0) {
        for (DrawAnnotation *theAnnotation in self.annotations) {
            if (nil != theAnnotation.bezierPath) {
                [theAnnotation.color setStroke];
                [theAnnotation.bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:1];
            }        
        }
    }
    
    // draw current path
    if (nil != self.annotation.bezierPath) {
        [self.annotation.color setStroke];
        [self.annotation.bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:1];
    }
}

- (void)drawPoint:(CGPoint)point endDrawing:(BOOL)end
{
    if (nil == self.annotation) {
        self.annotation = [[DrawAnnotation alloc] init];
        self.annotation.bezierPath = [UIBezierPath bezierPath];
        self.annotation.bezierPath.lineWidth = [self.pen.lineWidth intValue];
        self.annotation.color = self.pen.color;
        [self.annotation.bezierPath moveToPoint:point];
    } else {
        [self.annotation.bezierPath addLineToPoint:point];
    }
    
    [self setNeedsDisplay];
    
    if (end) {
        [self.annotations addObject:self.annotation];
        self.annotation = nil;
    }
}

- (void)clearPage
{
    [self.annotations removeAllObjects];
    self.annotation = nil;
    [self setNeedsDisplay];
}




@end
