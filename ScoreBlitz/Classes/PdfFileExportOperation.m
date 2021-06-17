//
//  PdfFileExportOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.03.15.
//
//

#import "PdfFileExportOperation.h"
#import "Score.h"
#import "Page.h"
#import "SignAnnotation.h"
#import "PrintSignAnnotation.h"

@implementation PdfFileExportOperation

#pragma mark - NSOperation Interface

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled] || self.score == nil)
    {
        // Must move the operation to the finished state if it is canceled.
        [self finishOperation];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    if (self.withAnnotations) {
        [self exportPdfFileWithAnnotations];
    } else {
        self.exportFilePath = [self.score pdfFilePath];
        [self finishOperation]; // automatically fires completion block
    }
}

#pragma mark - Export

- (void)exportPdfFileWithAnnotations
{
    NSString *exportDirectory = [self exportDirectoryPath];
    
    // get the base pdf file and the amount of pages
    CGPDFDocumentRef oldPdfDocument = CGPDFDocumentCreateWithURL ((__bridge CFURLRef) [self.score scoreUrl]);
    NSInteger numberOfPages = CGPDFDocumentGetNumberOfPages ((CGPDFDocumentRef) oldPdfDocument);
    
    // ceate path for new pdf
    self.exportFilePath = [exportDirectory stringByAppendingPathComponent:[[self createFileName] stringByAppendingPathExtension:kPdfFileExtension]];
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.exportFilePath]) {
#ifdef DEBUG
        NSLog(@"%s: file exists at path: %@", __func__, self.exportFilePath);
#endif
        [[NSFileManager defaultManager] removeItemAtPath:self.exportFilePath error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"%s: %@, %@", __func__, error, [error userInfo]);
#endif
            
            self.errorMessage = [error localizedDescription];
            self.failure = YES;
            [self finishOperation]; // automatically fires completion block
        }
    }
    
    // create new CG context to render the pdf
    NSDictionary *pdfMetaDataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           self.score.name, kCGPDFContextTitle,
                                           @"iRollMusic", kCGPDFContextCreator, nil];
    
    CGContextRef currentContext;
    if (UIGraphicsBeginPDFContextToFile (self.exportFilePath, CGRectZero, pdfMetaDataDictionary)) {
        currentContext = UIGraphicsGetCurrentContext();
    } else {
#ifdef DEBUG
        NSLog(@"%s: Could not create a new pdf context", __func__);
#endif
        self.errorMessage = @"Could not create a new pdf context";
        self.failure = YES;
        [self finishOperation]; // automatically fires completion block 
    }
    
    // draw single pdf pages into newPdfContext
    NSInteger counter;
    for (counter = 1; counter <= numberOfPages; counter++) {
        
        @autoreleasepool {
            
            // get box sizes from old pdf page
            CGPDFPageRef currentPdfPage = CGPDFDocumentGetPage(oldPdfDocument, counter);
            CGRect currentMediaBox = CGPDFPageGetBoxRect(currentPdfPage, kCGPDFMediaBox);
            CGRect currentCropBox = CGPDFPageGetBoxRect(currentPdfPage, kCGPDFCropBox);
            
            
            // create rotation angle for pdf page
            NSInteger pageRotationAngle = CGPDFPageGetRotationAngle(currentPdfPage);
            if (pageRotationAngle % 90 != 0) {
                pageRotationAngle = 0;
            }
            NSInteger adjustedRotationAngle = [self.score.rotationAngle intValue] + pageRotationAngle;
            adjustedRotationAngle = adjustedRotationAngle % 360;
            
            // calculate scale
            CGRect contentRect = CGRectMake(0, 0, currentMediaBox.size.width, currentMediaBox.size.height);
            CGSize pageVisibleSize = CGSizeMake(currentCropBox.size.width, currentCropBox.size.height);
            if ((adjustedRotationAngle == 90) || (adjustedRotationAngle == 270)) {
                contentRect = CGRectMake(0, 0, currentMediaBox.size.height, currentMediaBox.size.width);
                pageVisibleSize = CGSizeMake(currentCropBox.size.height, currentCropBox.size.width);
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
            
            // open new pdf page
            UIGraphicsBeginPDFPageWithInfo (contentRect, nil);
            
            // Setup the coordinate system.
            // Top left corner of the displayed page must be located at the point specified by the 'point' parameter.
            CGContextTranslateCTM(currentContext, drawOrigin.x, drawOrigin.y);
            
            // Scale the page to desired zoom level.
            CGContextScaleCTM(currentContext, scale, scale);
            
            CGContextSaveGState(currentContext);
            
            // The coordinate system must be set to match the PDF coordinate system.
            switch (adjustedRotationAngle) {
                case 0:
                    CGContextTranslateCTM(currentContext, 0, currentCropBox.size.height);
                    CGContextScaleCTM(currentContext, 1, -1);
                    break;
                case 90:
                    CGContextScaleCTM(currentContext, 1, -1);
                    CGContextRotateCTM(currentContext, -M_PI / 2);
                    break;
                case 180:
                case -180:
                    CGContextScaleCTM(currentContext, 1, -1);
                    CGContextTranslateCTM(currentContext, currentCropBox.size.width, 0);
                    CGContextRotateCTM(currentContext, M_PI);
                    break;
                case 270:
                case -90:
                    CGContextTranslateCTM(currentContext, currentCropBox.size.height, currentCropBox.size.width);
                    CGContextRotateCTM(currentContext, M_PI / 2);
                    CGContextScaleCTM(currentContext, -1, 1);
                    break;
            }
            
            // The CropBox defines the page visible area, clip everything outside it.
            CGRect clipRect = CGRectMake(0, 0, currentCropBox.size.width, currentCropBox.size.height);
            CGContextAddRect(currentContext, clipRect);
            CGContextClip(currentContext);
            
            CGContextTranslateCTM(currentContext, -currentCropBox.origin.x, -currentCropBox.origin.y);
            
            
            // draw pdf page
            CGContextSetInterpolationQuality(currentContext, kCGInterpolationHigh);
            CGContextSetRenderingIntent(currentContext, kCGRenderingIntentDefault);
            CGContextDrawPDFPage(currentContext, currentPdfPage);
            
            CGContextRestoreGState(currentContext);
            
            if ([self.score.isAnalyzed boolValue]) {
                // draw annotations into image
                UIGraphicsBeginImageContextWithOptions(pageVisibleSize, NO, 1);
                
                NSArray *pages = [NSArray arrayWithArray:self.score.orderedPagesAsc];
                
                Page *page = [pages objectAtIndex:counter - 1];
                
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
                    UIColor *color = [colorsForBezierPaths objectAtIndex:index];
                    [color  setStroke];
                    [bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:[[alphaForBezierPaths objectAtIndex:index] floatValue]];
                }
                
                UIImage *annotationsImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                // draw image into pdf context
                CGRect imageRect = CGRectMake(0, 0, pageVisibleSize.width, pageVisibleSize.height);
                [annotationsImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1];
                
                // text annotations are not drawn into image
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
    
    UIGraphicsEndPDFContext();
    CGPDFDocumentRelease(oldPdfDocument);
    
    [self finishOperation]; // automatically fires completion block
}

@end
