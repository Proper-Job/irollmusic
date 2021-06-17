//
//  ScoreAnalysingOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.01.15.
//
//

#import "ScoreAnalysingOperation.h"
#import "ScoreBlitzAppDelegate.h"
#import "Score.h"
#import "Page.h"
#import "UIImage+Resize.h"
#import "MetricsManager.h"

typedef void (^ScoreAnalysingOperationProgressBlock)(NSString *scoreName, CGFloat progress);

@interface ScoreAnalysingOperation ()

@property (nonatomic, assign) BOOL failure;
@property (readwrite, nonatomic, copy) ScoreAnalysingOperationProgressBlock operationProgressBlock;

@end

@implementation ScoreAnalysingOperation

#pragma mark - Accessors

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

#pragma mark - Init

- (id)initWithObjectID:(NSManagedObjectID*)scoreId
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        
        self.failure = NO;
        self.scoreId = scoreId;
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^)(NSManagedObjectID *scoreId))success
                              failure:(void (^)(NSManagedObjectID *scoreId))failure
{
    // Completion Block is nilled out by NSOparation on iOS 8.0 and later
    __weak ScoreAnalysingOperation *weakOperation = self;
    
    self.completionBlock = ^{
        ScoreAnalysingOperation *strongOperation = weakOperation;
        
        if (strongOperation.failure) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(strongOperation.scoreId);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(strongOperation.scoreId);
                });
            }
        }
    };
}

- (void)setProgressBlock:(void (^)(NSString *scoreName, CGFloat progress))block
{
    self.operationProgressBlock = block;
}

#pragma mark - NSOperation Interface

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled] || self.scoreId == nil)
    {
        // Must move the operation to the finished state if it is canceled.
        [self finishOperation];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.managedObjectContext.parentContext = UIAppDelegate.managedObjectContext;
    self.managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;

    NSError *error = nil;
    self.score = (Score*)[self.managedObjectContext existingObjectWithID:self.scoreId error:&error];
    
    if (error != nil && APP_DEBUG) {
        NSLog([NSString stringWithFormat:@"%s: error:%@", __func__, [error localizedDescription]]);
    }
    
    if (self.score == nil) {
        self.failure = YES;
        [self finishOperation];
    } else {
        [self analyse];
    }
}

/*
- (void)cancel
{
    BOOL cancelledBeforeExecution = ![self isExecuting] && ![self isCancelled];
    [super cancel];
    
    if (cancelledBeforeExecution) {
        // Super class calls start method which moves operation to finished state
    } else {
        // Cancel Analysing
        
        // Reverse core data changes
        //[self.managedObjectContext reset];
        //self.managedObjectContext = nil;
        
        //[self finishOperation];
    }
}*/

#pragma mark -  Lifetime

- (void)updateProgress:(CGFloat)progress
{
    if (self.operationProgressBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.operationProgressBlock(self.score.name, progress);
        });
    }
}

- (void)finishOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Analysing

- (void)analyse
{
    CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[self.score scoreUrl]);
    
    if (NULL == pdfDoc) {
#ifdef DEBUG
        NSLog(@"Couldn't open pdf file in analyzeScore: for score: %@", self.score);
#endif
        [self finishOperation];
        return;
    }
    
    self.numberOfPages = 0;
    
    if ([self.score.pages count] > 0) {
        self.numberOfPages = [self.score.pages count];
    }else {
        self.numberOfPages = (NSInteger) CGPDFDocumentGetNumberOfPages(pdfDoc);
    }
    
    // send first message to delegate with zero value
    [self updateProgress:0];
    
    NSInteger rotationAngle = [self.score.rotationAngle intValue];
    CGFloat canvasHeight = 0;

    if ([self.score.pages count] > 0) {
        for (Page *page in [self.score orderedPagesAsc]) {
            if ([self isCancelled]) {
                break;
            }
            
            int i = [page.number intValue];
            
            CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDoc, i);
            NSInteger pageRotationAngle = CGPDFPageGetRotationAngle(pageRef);
            if (pageRotationAngle % 90 != 0) {
                pageRotationAngle = 0;
            }
            NSInteger effectiveRotationAngle = (rotationAngle + pageRotationAngle) % 360;
            
            CGRect contentBox = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
            contentBox.origin.x = roundf(contentBox.origin.x);
            contentBox.origin.y = roundf(contentBox.origin.y);
            
            [page setContentBox:contentBox];
            if (90 == effectiveRotationAngle || 270 == effectiveRotationAngle) { // flip the box
                [page flipContentBox];
                contentBox = [page contentBox];
            }
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Page position on canvas as well as width and height are identical for portrait and landscape.
            // This is straightened out with sane methods on the page object so we can avoid tedious database migrations
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            page.positionOnCanvasPortrait = @(canvasHeight);
            page.positionOnCanvasLandscape = @(canvasHeight);
            
            CGFloat magnificationFactor = [MetricsManager scoreWidthAtFullScale] / contentBox.size.width;
            CGFloat pageHeight = roundf(contentBox.size.height * magnificationFactor);
            
            canvasHeight += pageHeight;
            
            page.heightPortrait = @(pageHeight);
            page.heightLandscape = @(pageHeight);
            page.widthPortrait = @([MetricsManager scoreWidthAtFullScale]);
            page.widthLandscape = @([MetricsManager scoreWidthAtFullScale]);
            
            [self createPreviewImagesForPage:page andPdf:pageRef];
            
            if (![self isCancelled]) {
                [self updateProgress:((float)i / (float)self.numberOfPages)];
            }
        }
    } else {
        for (int i = 1; i <= self.numberOfPages; i++) {
            if ([self isCancelled]) {
                break;
            }
            
            CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDoc, i);
            NSInteger pageRotationAngle = CGPDFPageGetRotationAngle(pageRef);
            if (pageRotationAngle % 90 != 0) {
                pageRotationAngle = 0;
            }
            NSInteger effectiveRotationAngle = (rotationAngle + pageRotationAngle) % 360;
            
            CGRect contentBox = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
            contentBox.origin.x = roundf(contentBox.origin.x);
            contentBox.origin.y = roundf(contentBox.origin.y);
            
            Page *page = (Page *) [[NSManagedObject alloc] initWithEntity:[Page entityDescription]
                                           insertIntoManagedObjectContext:self.managedObjectContext];
            
            [self.score addPagesObject:page];
            page.number = @(i);
            
            [page setContentBox:contentBox];
            if (90 == effectiveRotationAngle || 270 == effectiveRotationAngle) { // flip the box
                [page flipContentBox];
                contentBox = [page contentBox];
            }

            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Page position on canvas as well as width and height are identical for portrait and landscape.
            // This is straightened out with sane methods on the page object so we can avoid tedious database migrations
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            page.positionOnCanvasPortrait = @(canvasHeight);
            page.positionOnCanvasLandscape = @(canvasHeight);
            
            CGFloat magnificationFactor = [MetricsManager scoreWidthAtFullScale] / contentBox.size.width;
            CGFloat pageHeight = roundf(contentBox.size.height * magnificationFactor);

            canvasHeight += pageHeight;
            
            page.heightPortrait = @(pageHeight);
            page.heightLandscape = @(pageHeight);
            page.widthPortrait = @([MetricsManager scoreWidthAtFullScale]);
            page.widthLandscape = @([MetricsManager scoreWidthAtFullScale]);
            
            [self createPreviewImagesForPage:page andPdf:pageRef];
            
            if (![self isCancelled]) {
                [self updateProgress:((float)i / (float)self.numberOfPages)];
            }
        }
    }
    if ([self isCancelled]) {
        if (APP_DEBUG) {
            NSLog(@"Analyzing cancelled");
        }
        [self.managedObjectContext reset];
    }else {
        canvasHeight += [MetricsManager scrollingPagePadding] * (self.numberOfPages -1);

        self.score.canvasHeightPortrait = @(ceilf(canvasHeight));
        self.score.canvasHeightLandscape = @(ceilf(canvasHeight));

        self.score.isAnalyzed = @YES;
        
        NSError *error;
        if(![self.managedObjectContext save:&error]) {
#ifdef DEBUG
            NSLog(@"Error saving context in analyze score: %@", [error localizedDescription]);
#endif
        }
    }
    
    // Cleanup
    CGPDFDocumentRelease(pdfDoc);
    self.managedObjectContext = nil;
    [self finishOperation]; // automatically fires completion block
}

- (void)createPreviewImagesForPage:(Page *)thePage andPdf:(CGPDFPageRef)pdfPage
{
    CGPDFPageRetain(pdfPage);
    
    @autoreleasepool {
        
        CGRect contentBox = [thePage contentBox];
        UIImage *previewImage = nil;
        CGFloat scale = [MetricsManager scoreWidthAtFullScale] / contentBox.size.width;
        
        NSInteger rotationAngle = [thePage.score.rotationAngle intValue];
        NSInteger pageRotationAngle = CGPDFPageGetRotationAngle(pdfPage);
        if (pageRotationAngle % 90 != 0) {
            pageRotationAngle = 0;
        }
        NSInteger effectiveRotationAngle = (rotationAngle + pageRotationAngle ) % 360;
        
        CGSize imageSize = CGSizeMake(roundf(contentBox.size.width * scale), roundf(contentBox.size.height * scale));
        
        // Create a bitmap representation of the PDF page
        UIGraphicsBeginImageContextWithOptions(imageSize, // The size (measured in points) of the new bitmap context
                                               YES, // A Boolean flag indicating whether the bitmap is opaque
                                               1.0); // The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // First fill the background with white.
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        //CGContextSetRGBFillColor(context, (CGFloat)rand()/(CGFloat)RAND_MAX, (CGFloat)rand()/(CGFloat)RAND_MAX, (CGFloat)rand()/(CGFloat)RAND_MAX, 1.0);
        CGContextFillRect(context, (CGRect){0, 0, imageSize});
        
        CGFloat offsetX = contentBox.origin.x;
        CGFloat offsetY = contentBox.origin.y;
        
        if (0 == effectiveRotationAngle) {
            CGContextTranslateCTM(context, 0.0, imageSize.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextScaleCTM(context, scale, scale);
        }else if (90 == effectiveRotationAngle) {
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextScaleCTM(context, scale, scale);
            CGContextRotateCTM(context, degreesToRadian(-effectiveRotationAngle));
        }else if (180 == effectiveRotationAngle) {
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, imageSize.width, 0.0);
            CGContextScaleCTM(context, scale, scale);
            CGContextRotateCTM(context, degreesToRadian(-effectiveRotationAngle));
        }else if (270 == effectiveRotationAngle) {
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, imageSize.width, -imageSize.height);
            CGContextScaleCTM(context, scale, scale);
            CGContextRotateCTM(context, degreesToRadian(-effectiveRotationAngle));
        }
        
        CGContextTranslateCTM(context, -offsetX , -offsetY);
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
        CGContextDrawPDFPage(context, pdfPage);
        
        previewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        // Tile image and write tiles to disk
        CGSize gridSize = kScoreImageTileSize;
        CGFloat cols =  previewImage.size.width / gridSize.width;
        CGFloat rows = previewImage.size.height / gridSize.height;
        
        int fullColumns = floorf(cols);
        int fullRows = floorf(rows);
        
        CGFloat remainderWidth = previewImage.size.width - (fullColumns * gridSize.width);
        CGFloat remainderHeight = previewImage.size.height - (fullRows * gridSize.height);
        
        
        if (cols > fullColumns) fullColumns++;
        if (rows > fullRows) fullRows++;
        
        CGImageRef fullImage = previewImage.CGImage;
        CGImageRetain(fullImage);
        
        for (int y = 0; y < fullRows; y++) {
            for (int x = 0; x < fullColumns; x++) {
                @autoreleasepool {
                    CGSize tileSize = gridSize;
                    if (x + 1 == fullColumns && remainderWidth > 0) {
                        // Last column
                        tileSize.width = remainderWidth;
                    }
                    if (y + 1 == fullRows && remainderHeight > 0) {
                        // Last row
                        tileSize.height = remainderHeight;
                    }
                    CGRect tileRect = CGRectMake(x * gridSize.width,
                                                 y * gridSize.height,
                                                 tileSize.width,
                                                 tileSize.height);
                    CGImageRef tileImage = CGImageCreateWithImageInRect(fullImage, tileRect);
                    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:tileImage]);
                    NSString *path = [[thePage.score scoreDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:kScoreImageTileFormatString,
                                                                                                     [thePage.number intValue], x, y]];
                    [imageData writeToFile:path atomically:YES];
                    CGImageRelease(tileImage);
                }
            }
        }
        CGImageRelease(fullImage);
        
        // Make the large preview image
        @autoreleasepool {
            CGSize largeSize = CGSizeMake(
                    roundf(previewImage.size.width * [MetricsManager scorePreviewReductionFactor]),
                    roundf(previewImage.size.height * [MetricsManager scorePreviewReductionFactor])
            );
            UIImage *previewImageLarge = [previewImage resizedImage:largeSize
                                               interpolationQuality:kCGInterpolationDefault];
            NSString *largePreviewPath = [[thePage.score scoreDirectory] stringByAppendingPathComponent:[NSString
                    stringWithFormat:kPreviewImageLargeFormatString, [thePage.number intValue]]];
            [[NSFileManager defaultManager] createFileAtPath:largePreviewPath
                                                    contents:UIImagePNGRepresentation(previewImageLarge)
                                                  attributes:nil];
        }
        
        // Make the small preview image
        // This is an ass backwards way to figure out the reduction scale, but hey it works.
        CGFloat reductionScale = 1.0f;
        if ([thePage isPortrait]) {
            reductionScale = kPreviewImageHeightSmall / previewImage.size.height;
        }else {
            reductionScale = kPreviewImageWidthSmall / previewImage.size.width;
        }
        CGSize smallSize = CGSizeMake(roundf(previewImage.size.width * reductionScale),
                                      roundf(previewImage.size.height * reductionScale));
        UIImage *previewImageSmall = [previewImage resizedImage:smallSize
                                           interpolationQuality:kCGInterpolationDefault];
        NSString *smallPreviewPath = [[thePage.score scoreDirectory] stringByAppendingPathComponent:[NSString
                stringWithFormat:kPreviewImageSmallFormatString, [thePage.number intValue]]];
        [[NSFileManager defaultManager] createFileAtPath:smallPreviewPath
                                                contents:UIImagePNGRepresentation(previewImageSmall)
                                              attributes:nil];
    }
    
    CGPDFPageRelease(pdfPage);
}


@end
