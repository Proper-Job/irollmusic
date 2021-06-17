//
//  PrintSignAnnotation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"

@class SVGDocument;

@interface PrintSignAnnotation : CPTLayer

@property (nonatomic, strong) SVGDocument *svgDocument;
@property (nonatomic, strong) UIColor *color;

@end
