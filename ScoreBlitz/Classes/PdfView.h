//
//  PagingPdfView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PerformanceAnnotationView, Score;

@interface PdfView : UIView {    
    CGPDFDocumentRef _pdfDoc;
    CGPDFPageRef _pdfPage;
}
@property (strong) Score *score;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) NSInteger index, rotationAngle;
@property (nonatomic, assign) CGRect contentBox;
@property (nonatomic, strong) PerformanceAnnotationView *annotationView;

- (void)invalidate;
- (void)willDisplay;
@end
