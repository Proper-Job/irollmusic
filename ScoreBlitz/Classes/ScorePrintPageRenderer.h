//
//  ScorePrintPageRenderer.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScorePrintPageRenderer : UIPrintPageRenderer {
    Score *_score;
    CGPDFDocumentRef _pdfDocument;
    NSArray *_annotations;
}

@property (nonatomic, assign) BOOL printAnnotations;

- (id)initWithScore:(Score *)theScore;


@end
