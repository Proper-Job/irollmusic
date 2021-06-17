//
//  DropboxFileDeleteOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import "DropboxFileDeleteOperation.h"

@implementation DropboxFileDeleteOperation

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
    __weak DropboxFileDeleteOperation *weakOperation = self;
    
    self.completionBlock = ^{
        DropboxFileDeleteOperation *strongOperation = weakOperation;
        
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
    
    //[self.dbRestClient deletePath:self.dropboxFile.path];
    
    [[self.dbUserClient.filesRoutes deleteV2:self.dropboxFile.pathLower] setResponseBlock:^(DBFILESDeleteResult * _Nullable result, DBFILESDeleteError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result) {
            self.failure = NO;
            [self finishOperation];
        } else {
            NSLog(@"%@\n%@\n", routeError, networkError);
            self.failure = YES;
            [self finishOperation]; // fires completion block automatically
        }
    }];
}

/*
#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
    self.failure = NO;
    [self finishOperation];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
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
