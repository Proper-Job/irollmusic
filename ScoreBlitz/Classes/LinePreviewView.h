//
//  LinePreviewView.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 28.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawAnnotation, AnnotationPen;

@interface LinePreviewView : UIView {
    
}

@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) DrawAnnotation *annotation;
@property (nonatomic, strong) AnnotationPen *pen;

- (void)drawPoint:(CGPoint)point endDrawing:(BOOL)end;
- (void)clearPage;

@end
