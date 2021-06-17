//
//  DropboxFileOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import <Foundation/Foundation.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

typedef void (^DropboxFileOperationProgressBlock)(CGFloat progress);

@interface DropboxFileOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic, strong) DBUserClient *dbUserClient;
@property (nonatomic, strong) NSString *filePath, *errorMessage;

@property (nonatomic, assign) BOOL failure;
@property (readwrite, nonatomic, copy) DropboxFileOperationProgressBlock operationProgressBlock;

- (void)setProgressBlock:(void (^)(CGFloat progress))block;

- (void)finishOperation;

@end


