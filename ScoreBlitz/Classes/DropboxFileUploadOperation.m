//
//  DropboxFileTransferOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "DropboxFileUploadOperation.h"

@implementation DropboxFileUploadOperation

#pragma mark - Init

- (id)initWithFilePath:(NSString*)filePath
{
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;

        self.filePath = filePath;
        
        self.dbUserClient = [DBClientsManager authorizedClient];
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *uploadPath))success
                              failure:(void (^)(NSString *errorMessage))failure
{
    // Completion Block is nilled out by NSOperation on iOS 8.0 and later
    __weak DropboxFileUploadOperation *weakOperation = self;
    
    self.completionBlock = ^{
        DropboxFileUploadOperation *strongOperation = weakOperation;
        
        if (strongOperation.failure) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(strongOperation.errorMessage);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(strongOperation.uploadPath);
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
    if ([self isCancelled] || self.filePath == nil)
    {
        // Must move the operation to the finished state if it is canceled.
        [self finishOperation];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self startUpload];
}

- (void)cancel
{
    BOOL cancelledBeforeExecution = ![self isExecuting] && ![self isCancelled];
    [super cancel];
    
    if (cancelledBeforeExecution) {
        // Super class calls start method which moves operation to finished state
    } else {
        // Cancel Task
        if (self.dbUploadTask) {
            [self.dbUploadTask cancel];
        }
        
        // Delete Files??
        
        [self finishOperation];
    }
}

#pragma mark - Upload

- (void)startUpload
{
    NSData *fileData = [NSData dataWithContentsOfFile:self.filePath];
    self.uploadPath = [@"/" stringByAppendingString:[self.filePath lastPathComponent]];
    
    DBFILESWriteMode *writeMode = [[DBFILESWriteMode alloc] initWithAdd];
    
    self.dbUploadTask = [[[self.dbUserClient.filesRoutes uploadData:self.uploadPath
                           mode:writeMode
                           autorename:@(YES)
                           clientModified:nil
                           mute:@(NO)
                           inputData:fileData]
     setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
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

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    if (nil == metadata) {
        self.failure = YES;
        [self finishOperation]; // fires completion block automatically
    } else {
        NSIndexSet *indexSetOfMetadataContainsFileName = [metadata.contents indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[[(DBMetadata *)obj path] lastPathComponent] isEqualToString:[self.filePath lastPathComponent]];
        }];
        
        if ([indexSetOfMetadataContainsFileName count] > 0) {
            NSString *fileExtension = [self.filePath pathExtension];
            NSString *oldFileName = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
            NSString *newFileName = [self.filePath lastPathComponent];
            NSInteger counter = 1;
            
            while ([[metadata.contents indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [[[(DBMetadata *)obj path] lastPathComponent] isEqualToString:newFileName];
            }] count] > 0) {
                newFileName = [oldFileName stringByAppendingString:[NSString stringWithFormat:@"-%ld.%@", (long)counter, fileExtension]];
                counter ++;
            }
            
            [self.dbRestClient uploadFile:newFileName toPath:@"/" withParentRev:nil fromPath:self.filePath];
            self.uploadPath = [@"/" stringByAppendingString:newFileName];
        } else {
            [self.dbRestClient uploadFile:[self.filePath lastPathComponent] toPath:@"/" withParentRev:nil fromPath:self.filePath];
            self.uploadPath = [@"/" stringByAppendingString:[self.filePath lastPathComponent]];
        }
    }
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    if (nil != error) {
        self.errorMessage = [error localizedDescription];
        if (APP_DEBUG) {
            NSLog(@"%s: %@ : %@", __func__ , error, [error localizedDescription]);
        }
    }
    
    self.failure = YES;
    [self finishOperation]; // fires completion block automatically
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    self.failure = NO;
    [self finishOperation];
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath from:(NSString*)srcPath
{
    if (self.operationProgressBlock) {
        self.operationProgressBlock(progress);
    }
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
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
