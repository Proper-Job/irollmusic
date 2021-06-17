//
//  PagingPdfView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "PdfView.h"
#import "PerformanceAnnotationView.h"
#import "Score.h"


@implementation PdfView

+ (Class)layerClass {
	return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _pdfDoc = NULL;
        _pdfPage = NULL;
        
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
		// levelsOfDetail and levelsOfDetailBias determine how
		// the layer is rendered at different zoom levels.
        tiledLayer.levelsOfDetail = 3;  // 1x, 1/2x, 1/4x
		tiledLayer.levelsOfDetailBias = 2;  // changes LOD to 4x, 2x, 1x, specifies the zoomlevels used for zooming in (i.e. magifying)
		tiledLayer.tileSize = CGSizeMake(512.0, 512.0);


        self.annotationView = [[PerformanceAnnotationView alloc] initWithFrame:CGRectZero];
        self.annotationView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.annotationView];
        [self bringSubviewToFront:self.annotationView];
    }
    return self;
}

- (id)init {
    return  [self initWithFrame:CGRectZero];
}

- (void)invalidate
{
    self.layer.contents = nil;
    
    CGPDFDocumentRelease(_pdfDoc);
    CGPDFPageRelease(_pdfPage);
    _pdfDoc = NULL;
    _pdfPage = NULL;

    self.rotationAngle = 0;
    if (APP_DEBUG) {
        NSLog(@"Invalidating pdf page: %ld", self.index + 1);
    }
}

- (void)willDisplay
{
    _pdfDoc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[self.score scoreUrl]);
    _pdfPage = CGPDFDocumentGetPage(_pdfDoc, self.index + 1);
    CGPDFPageRetain(_pdfPage);
    
    NSInteger pageRotationAngle = CGPDFPageGetRotationAngle(_pdfPage);
    if (pageRotationAngle % 90 != 0) {
        pageRotationAngle = 0;
    }
    self.rotationAngle = [self.score.rotationAngle intValue];
    self.rotationAngle += pageRotationAngle;
    self.rotationAngle = self.rotationAngle % 360;
    
    [self.layer setNeedsDisplay];
    [self.annotationView setNeedsDisplay];
}

-(void)drawRect:(CGRect)r
{
    // UIView uses the existence of -drawRect: to determine if it should allow its CALayer
    // to be invalidated, which would then lead to the layer creating a backing store and
    // -drawLayer:inContext: being called.
    // By implementing an empty -drawRect: method, we allow UIKit to continue to implement
    // this logic, while doing our real drawing work inside of -drawLayer:inContext:
}


// Draw the CGPDFPageRef into the layer at the correct scale.
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    //[Helpers printFrame:CGContextGetClipBoundingBox(context) description:@"clip box"];
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    //CGContextSetRGBFillColor(context, (CGFloat)rand()/(CGFloat)RAND_MAX, (CGFloat)rand()/(CGFloat)RAND_MAX, (CGFloat)rand()/(CGFloat)RAND_MAX, 1.0);
    CGContextFillRect(context, self.bounds);
        
    CGFloat offsetX = self.contentBox.origin.x;
    CGFloat offsetY = self.contentBox.origin.y;
    
    if (0 == self.rotationAngle) {
        CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextScaleCTM(context, self.scale, self.scale);
    }else if (90 == self.rotationAngle) {
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextScaleCTM(context, self.scale, self.scale);
        CGContextRotateCTM(context, degreesToRadian(-self.rotationAngle));
    }else if (180 == self.rotationAngle) {
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, self.bounds.size.width, 0.0);
        CGContextScaleCTM(context, self.scale, self.scale);
        CGContextRotateCTM(context, degreesToRadian(-self.rotationAngle));
    }else if (270 == self.rotationAngle) {
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, self.bounds.size.width, -self.bounds.size.height);
        CGContextScaleCTM(context, self.scale, self.scale);
        CGContextRotateCTM(context, degreesToRadian(-self.rotationAngle));
    }
            
    CGContextTranslateCTM(context, -offsetX , -offsetY);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
    if (NULL != _pdfPage) {
        CGContextDrawPDFPage(context, _pdfPage);
    }
    

}

#pragma mark - Memory Management

- (void)dealloc {
    CGPDFDocumentRelease(_pdfDoc);
    CGPDFPageRelease(_pdfPage);

#ifdef DEBUG
    NSLog(@"Releasing pdf page: %d", self.index + 1);
#endif

    
}


@end
