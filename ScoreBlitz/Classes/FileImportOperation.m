//
//  FileImportOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import "FileImportOperation.h"

@implementation FileImportOperation

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

- (id)initWithFilePath:(NSString*)filePath
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        
        self.filePath = filePath;
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *filePath))success
                              failure:(void (^)(NSString *errorMessage))failure
{
    // Completion Block is nilled out by NSOperation on iOS 8.0 and later
    __weak FileImportOperation *weakOperation = self;
    
    self.completionBlock = ^{
        FileImportOperation *strongOperation = weakOperation;
        
        if (strongOperation.failure) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(strongOperation.errorMessage);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(strongOperation.filePath);
                });
            }
        }
    };
}

#pragma mark -  Lifetime

- (void)finishOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
