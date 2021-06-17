//
//  DropboxFileDownloadOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "DropboxFileOperation.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface DropboxFileDownloadOperation : DropboxFileOperation

@property (nonatomic, strong) DBFILESFileMetadata *dropboxFile;
@property (nonatomic, strong) DBDownloadUrlTask *downloadTask;

- (id)initWithDropboxFile:(DBFILESFileMetadata*)dropboxFile;

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *filePath))success
                              failure:(void (^)(NSString *errorMessage))failure;


@end
