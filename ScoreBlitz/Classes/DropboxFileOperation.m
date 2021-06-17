//
//  DropboxFileOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "DropboxFileOperation.h"

@implementation DropboxFileOperation

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

- (void)setProgressBlock:(void (^)(CGFloat progress))block
{
    self.operationProgressBlock = block;
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
