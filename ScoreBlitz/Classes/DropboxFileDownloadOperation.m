//
//  DropboxFileDownloadOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "DropboxFileDownloadOperation.h"
#import "ScoreBlitzAppDelegate.h"
#import "QueryHelper.h"
#import "PdfFileImportOperation.h"
#import "IrmFileImportOperation.h"

@implementation DropboxFileDownloadOperation


#pragma mark - Init

- (id)initWithDropboxFile:(DBFILESFileMetadata*)dropboxFile
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        
        self.dropboxFile = dropboxFile;
        
        self.dbUserClient = [DBClientsManager authorizedClient];
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *filePath))success
                              failure:(void (^)(NSString *errorMessage))failure
{
    // Completion Block is nilled out by NSOperation on iOS 8.0 and later
    __weak DropboxFileDownloadOperation *weakOperation = self;
    
    self.completionBlock = ^{
        DropboxFileDownloadOperation *strongOperation = weakOperation;
        
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

#pragma mark - NSOperation Interface

- (void)start
{
    // DBRestClient needs main thread for callbacks
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil
                            waitUntilDone:NO];
        return;
    }
    
    // Always check for cancellation before launching the task.
    if ([self isCancelled] || self.dropboxFile == nil)
    {
        // Must move the operation to the finished state if it is canceled.
        [self finishOperation];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self startDownload];
}

- (void)cancel
{
    BOOL cancelledBeforeExecution = ![self isExecuting] && ![self isCancelled];
    [super cancel];
    
    if (cancelledBeforeExecution) {
        // Super class calls start method which moves operation to finished state
    } else {
        // Cancel Operations
        //[self.dbRestClient cancelAllRequests];
        
        if (self.downloadTask) {
            [self.downloadTask cancel];
        }
        
        // Delete Files??
        
        [self finishOperation];
    }
}

#pragma mark - Download

- (void)startDownload
{
    NSString *inboxDirectoryPath = [[UIAppDelegate applicationImportDirectory] path];    
    //self.filePath = [inboxDirectoryPath stringByAppendingPathComponent:[self.dropboxFile.path lastPathComponent]];
    //[self.dbRestClient loadFile:self.dropboxFile.path intoPath:self.filePath];
    
    self.filePath = [inboxDirectoryPath stringByAppendingPathComponent:self.dropboxFile.name];
    
    self.downloadTask = [[[self.dbUserClient.filesRoutes downloadUrl:self.dropboxFile.pathLower overwrite:NO destination:[NSURL fileURLWithPath:self.filePath]] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSURL * _Nonnull destination) {
        if (result) {
            self.failure = NO;
            [self finishOperation];
        } else {
            NSLog(@"%@\n%@\n", routeError, networkError);
            self.failure = YES;
            [self finishOperation]; // fires completion block automatically
        }
    }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        if (self.operationProgressBlock) {
            CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
            self.operationProgressBlock(progress);
        }
    }];
}
/*
#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    self.failure = NO;
    [self finishOperation];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath
{
    if (self.operationProgressBlock) {
        self.operationProgressBlock(progress);
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    if (nil != error) {
        self.errorMessage = [error localizedDescription];
        if (APP_DEBUG) {
            NSLog(@"%s: %@ : %@", __func__ , error, [error localizedDescription]);
        }
    }
    
    self.failure = YES;
    [self finishOperation]; // fires completion block automatically
}*/

@end
