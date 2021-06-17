//
//  FileExportOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.03.15.
//
//

#import "FileExportOperation.h"
#import "Score.h"
#import "TransferFile.h"

@implementation FileExportOperation

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

- (id)initWithScore:(Score*)score
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        
        self.score = score;
        self.withAnnotations = NO;
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *exportFilePath))success
                              failure:(void (^)(NSString *errorMessage))failure
{
    // Completion Block is nilled out by NSOperation on iOS 8.0 and later
    __weak FileExportOperation *weakOperation = self;
    
    self.completionBlock = ^{
        FileExportOperation *strongOperation = weakOperation;
        
        if (strongOperation.failure) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(strongOperation.errorMessage);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(strongOperation.exportFilePath);
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

#pragma mark - Export

- (NSString*)exportDirectoryPath
{
    NSError *error = nil;
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (nil == error) {
        return [directoryURL path];
    } else {
        if (APP_DEBUG) {
            NSLog(@"%s: Error while creating export directory", __func__);
        }
        return nil;
    }
}

- (NSString*)createFileName
{
    NSError *error = nil;
    
    // create stable filename
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_-]" options:NSRegularExpressionCaseInsensitive error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"exportScore: Error while creating regular expression: %@, %@", error, [error userInfo]);
#endif
        error = nil;
    }
    
    NSRange range = NSMakeRange(0, [self.score.name length]);
    NSString *scoreFileName = [regEx stringByReplacingMatchesInString:self.score.name options:NSRegularExpressionCaseInsensitive range:range withTemplate:@"_"];
    
    return scoreFileName;
}


@end
