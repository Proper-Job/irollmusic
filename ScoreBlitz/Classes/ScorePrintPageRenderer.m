//
//  ScorePrintPageRenderer.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScorePrintPageRenderer.h"
#import "Score.h"
#import "Page.h"
#import "SignAnnotation.h"
#import "PrintSignAnnotation.h"

@implementation ScorePrintPageRenderer

@synthesize printAnnotations;

- (id)initWithScore:(Score *)theScore
{
    self = [super init];
    if (self) {
        _score = theScore;
        _pdfDocument = CGPDFDocumentCreateWithURL ((__bridge CFURLRef) [_score scoreUrl]);
    }
    return self;
}


- (NSInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages ((CGPDFDocumentRef) _pdfDocument);
}

- (void)drawContentForPageAtIndex:(NSInteger)index inRect:(CGRect)contentRect
{ 
    // get context, pdf page and cropbox
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGPDFPageRef currentPdfPage = CGPDFDocumentGetPage(_pdfDocument, index + 1);
    CGRect cropBox = CGPDFPageGetBoxRect(currentPdfPage, kCGPDFCropBox);
    
    // create rotation angle for pdf page
    NSInteger pageRotationAngle = CGPDFPageGetRotationAngle(currentPdfPage);
    if (pageRotationAngle % 90 != 0) {
        pageRotationAngle = 0;
    }
    NSInteger adjustedRotationAngle = [_score.rotationAngle intValue] + pageRotationAngle;
    adjustedRotationAngle = adjustedRotationAngle % 360;
    
    // calculate scale
    CGSize pageVisibleSize = CGSizeMake(cropBox.size.width, cropBox.size.height);
	if ((adjustedRotationAngle == 90) || (adjustedRotationAngle == 270)) {
		pageVisibleSize = CGSizeMake(cropBox.size.height, cropBox.size.width);
	}
    
    float scaleX = contentRect.size.width / pageVisibleSize.width;
    float scaleY = contentRect.size.height / pageVisibleSize.height;
    float scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Offset relative to top left corner of rectangle where the page will be displayed
    float offsetX = 0;
    float offsetY = 0;
    
    float rectangleAspectRatio = contentRect.size.width / contentRect.size.height;
    float pageAspectRatio = pageVisibleSize.width / pageVisibleSize.height;
    
    if (pageAspectRatio < rectangleAspectRatio) {
        // The page is narrower than the rectangle, we place it at center on the horizontal
        offsetX = (contentRect.size.width - pageVisibleSize.width * scale) / 2;
    }
    else { 
        // The page is wider than the rectangle, we place it at center on the vertical
        offsetY = (contentRect.size.height - pageVisibleSize.height * scale) / 2;
    }
    
    CGPoint drawOrigin = CGPointMake(contentRect.origin.x + offsetX, contentRect.origin.y + offsetY);
    
    // Setup the coordinate system.
	// Top left corner of the displayed page must be located at the point specified by the 'point' parameter.
	CGContextTranslateCTM(currentContext, drawOrigin.x, drawOrigin.y);
	
	// Scale the page to desired zoom level.
	CGContextScaleCTM(currentContext, scale, scale);
    
    CGContextSaveGState(currentContext);
	
	// The coordinate system must be set to match the PDF coordinate system.
	switch (adjustedRotationAngle) {
		case 0:
			CGContextTranslateCTM(currentContext, 0, cropBox.size.height);
			CGContextScaleCTM(currentContext, 1, -1);
			break;
		case 90:
			CGContextScaleCTM(currentContext, 1, -1);
			CGContextRotateCTM(currentContext, -M_PI / 2);
			break;
		case 180:
		case -180:
			CGContextScaleCTM(currentContext, 1, -1);
			CGContextTranslateCTM(currentContext, cropBox.size.width, 0);
			CGContextRotateCTM(currentContext, M_PI);
			break;
		case 270:
		case -90:
			CGContextTranslateCTM(currentContext, cropBox.size.height, cropBox.size.width);
			CGContextRotateCTM(currentContext, M_PI / 2);
			CGContextScaleCTM(currentContext, -1, 1);
			break;
	}
	
	// The CropBox defines the page visible area, clip everything outside it.
	CGRect clipRect = CGRectMake(0, 0, cropBox.size.width, cropBox.size.height);
	CGContextAddRect(currentContext, clipRect);
	CGContextClip(currentContext);
	
	CGContextTranslateCTM(currentContext, -cropBox.origin.x, -cropBox.origin.y);

    // draw pdf page
    CGContextSetInterpolationQuality(currentContext, kCGInterpolationHigh);
    CGContextSetRenderingIntent(currentContext, kCGRenderingIntentDefault);
    CGContextDrawPDFPage(currentContext, currentPdfPage);
    
    CGContextRestoreGState(currentContext);
    
    if (self.printAnnotations && [_score.isAnalyzed boolValue]) {    // draw annotations if printing of annotations is enabled
        @autoreleasepool {
        
        // first render image for draw annotations
            UIGraphicsBeginImageContextWithOptions(pageVisibleSize, NO, 1);
            
            NSArray *pages = [NSArray arrayWithArray:_score.orderedPagesAsc];
            
            Page *page = [pages objectAtIndex:index];

            NSDictionary *annotations = [page annotationsDictionaryForFrameSize:pageVisibleSize invertY:NO];
            
            NSArray *bezierPaths = [annotations valueForKey:kAnnotationBezierPaths];
            NSArray *colorsForBezierPaths = [annotations valueForKey:kAnnotationBezierPathColors];
            NSArray *alphaForBezierPaths = [annotations valueForKey:kAnnotationBezierPathAlpha];
            
            
            NSArray *strings = [annotations valueForKey:kAnnotationStrings];
            NSArray *pointsForStrings = [annotations valueForKey:kAnnotationStringPoints];
            NSArray *fontNameForStrings = [annotations valueForKey:kAnnotationFontName];
            NSArray *fontSizeForStrings = [annotations valueForKey:kAnnotationFontSize];
            
            for (UIBezierPath *bezierPath in bezierPaths) {
                NSInteger index = [bezierPaths indexOfObject:bezierPath];
                [[colorsForBezierPaths objectAtIndex:index] setStroke];
                [bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:[[alphaForBezierPaths objectAtIndex:index] floatValue]];
            }
                    
            UIImage *annotationsImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // draw image into pdf context
            CGRect imageRect = CGRectMake(0, 0, pageVisibleSize.width, pageVisibleSize.height);
            [annotationsImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1];
            
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
            NSArray *signAnnotations = [page signAnnotationsForFrameSize:pageVisibleSize];
            for (SignAnnotation *signAnnotation in signAnnotations) {
                CGContextSaveGState(currentContext);
                CGContextTranslateCTM(currentContext, signAnnotation.caLayer.frame.origin.x, signAnnotation.caLayer.frame.origin.y);
                PrintSignAnnotation *printSignAnnotation = [[PrintSignAnnotation alloc] initWithFrame:signAnnotation.caLayer.frame];
                printSignAnnotation.svgDocument = signAnnotation.svgDocument;
                printSignAnnotation.color = signAnnotation.color;                
                [printSignAnnotation renderAsVectorInContext:currentContext];     
                CGContextRestoreGState(currentContext);
            }
        
        }
    }
}



- (void)dealloc
{
    CGPDFDocumentRelease(_pdfDocument);
    
}

@end
