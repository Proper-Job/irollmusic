//
//  ScoreRotationOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import "ScoreRotationOperation.h"
#import "ScoreBlitzAppDelegate.h"
#import "Score.h"
#import "Page.h"
#import "UIImage+Resize.h"
#import "MetricsManager.h"

typedef void (^ScoreRotationOperationProgressBlock)(NSString *scoreName, CGFloat progress);

@interface ScoreRotationOperation ()

@property (nonatomic, assign) BOOL failure;
@property (readwrite, nonatomic, copy) ScoreRotationOperationProgressBlock operationProgressBlock;

@end

@implementation ScoreRotationOperation

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
    __weak ScoreRotationOperation *weakOperation = self;
    
    self.completionBlock = ^{
        ScoreRotationOperation *strongOperation = weakOperation;
        
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
        [self startRotation];
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

#pragma mark - Lifetime

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

#pragma mark - Rotation

- (void)startRotation
{
    NSInteger newAngle = ([self.score.rotationAngle intValue] + 90) % 360;
    if (APP_DEBUG) {
        NSLog(@"%s: Rotating score clockwise to new angle: %d", __func__, newAngle);
    }

    NSArray *orderedPages = [self.score orderedPagesAsc];
    if ([orderedPages count] > 0) {
        [[orderedPages objectAtIndex:0] flipContentBox];
    }
    self.score.rotationAngle = @(newAngle);
    self.score.isAnalyzed = @NO;
    
    [self updateProgress:0.3];

    [self removeImageTilesForScore:self.score];
        [self updateProgress:0.6];
    
    [self generateFirstPagePreviewImagesForScore:self.score];
    [self updateProgress:0.9];
    
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        if (APP_DEBUG) {
            NSLog(@"Error saving context in analyze score: %@", [error localizedDescription]);
        }
    }

    [self updateProgress:1];
    self.managedObjectContext = nil;
    [self finishOperation]; // automatically fires completion block
}

- (void)removeImageTilesForScore:(Score *)theScore
{
    NSString *scoreDir = theScore.scoreDirectory;
    NSError *error = nil;
    NSArray *scoreDirectoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scoreDir
                                                                                error:&error];
    
    if(APP_DEBUG) {
        if (nil != error) {
            NSLog(@"%@ %s %d", [error localizedDescription], __FUNCTION__, __LINE__);
            error = nil;
        }
    }
    
    if ([scoreDirectoryContent count] > 0) {
        NSIndexSet *pngIndices = [scoreDirectoryContent indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[(NSString *)obj pathExtension] isEqualToString:@"png"];
        }];
        
        for (NSString *relativePngPath in [scoreDirectoryContent objectsAtIndexes:pngIndices]) {
            [[NSFileManager defaultManager] removeItemAtPath:[scoreDir stringByAppendingPathComponent:relativePngPath]
                                              error:&error];
        }
    }
}

- (void)generateFirstPagePreviewImagesForScore:(Score *)theScore
{
    if (0 == [theScore.pages count]) {
        if(APP_DEBUG) {
            NSLog(@"Score has no pages. %s %d", __FUNCTION__, __LINE__);
        }
        return;
    }
    
    @autoreleasepool {

        CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)theScore.scoreUrl);
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDoc, 1);
        if (NULL == pdfPage) {
            if(APP_DEBUG) {
                NSLog(@"Couldn't load pdf page %s %d", __FUNCTION__, __LINE__);
            }
            return;
        }
        
        Page *thePage = [theScore orderedPagesAsc][0];
        CGRect contentBox = [thePage contentBox];
        
        NSInteger rotationAngle = [theScore.rotationAngle intValue];
        NSInteger pageRotationAngle = CGPDFPageGetRotationAngle(pdfPage);
        if (pageRotationAngle % 90 != 0) {
            pageRotationAngle = 0;
        }
        NSInteger effectiveRotationAngle = (rotationAngle + pageRotationAngle) % 360;
        
        UIImage *largePreviewImage = nil;
        CGFloat scale = [MetricsManager scoreWidthAtFullScale] *
                [MetricsManager scorePreviewReductionFactor] /
                contentBox.size.width;
        
        CGSize imageSize = CGSizeMake(
                roundf(contentBox.size.width * scale),
                roundf(contentBox.size.height * scale)
        );
        
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
        
        CGContextTranslateCTM(context, -offsetX, -offsetY);
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
        CGContextDrawPDFPage(context, pdfPage);
        
        largePreviewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        CGPDFDocumentRelease(pdfDoc);
        
        NSString *largePreviewPath = [[thePage.score scoreDirectory] stringByAppendingPathComponent:[NSString
                stringWithFormat:kPreviewImageLargeFormatString, [thePage.number intValue]]];
        [[NSFileManager defaultManager] createFileAtPath:largePreviewPath
                                       contents:UIImagePNGRepresentation(largePreviewImage)
                                     attributes:nil];

        // Make the small preview image
        // This is an ass backwards way to figure out the reduction scale, but hey it works.
        CGFloat reductionScale = 1.0f;
        if ([thePage isPortrait]) {
            reductionScale = kPreviewImageHeightSmall / largePreviewImage.size.height;
        }else {
            reductionScale = kPreviewImageWidthSmall / largePreviewImage.size.width;
        }
        
        CGSize smallSize = CGSizeMake(roundf(largePreviewImage.size.width * reductionScale),
                                      roundf(largePreviewImage.size.height * reductionScale));
        UIImage *previewImageSmall = [largePreviewImage resizedImage:smallSize interpolationQuality:kCGInterpolationDefault];
        NSString *smallPreviewPath = [[thePage.score scoreDirectory] stringByAppendingPathComponent:[NSString
                stringWithFormat:kPreviewImageSmallFormatString, [thePage.number intValue]]];
        [[NSFileManager defaultManager] createFileAtPath:smallPreviewPath
                                       contents:UIImagePNGRepresentation(previewImageSmall)
                                     attributes:nil];
    }
}


@end
