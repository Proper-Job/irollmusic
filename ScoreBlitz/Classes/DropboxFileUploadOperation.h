//
//  DropboxFileTransferOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "DropboxFileOperation.h"

@class Score;

@interface DropboxFileUploadOperation : DropboxFileOperation

@property (nonatomic, strong) NSString *uploadPath;
@property (nonatomic, strong) DBUploadTask *dbUploadTask;

- (id)initWithFilePath:(NSString*)filePath;

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *uploadPath))success
                              failure:(void (^)(NSString *errorMessage))failure;

@end
