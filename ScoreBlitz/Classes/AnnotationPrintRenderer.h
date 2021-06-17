//
//  AnnotationPrintRenderer.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Page;

@interface AnnotationPrintRenderer : NSObject

+ (void)renderAnnotationsForPage:(Page*)page inContext:(CGContextRef)context forContextSize:(CGSize)contextSize;

@end
