//
//  DropboxFileDeleteOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import "DropboxFileOperation.h"

@interface DropboxFileDeleteOperation : DropboxFileOperation

@property (nonatomic, strong) DBFILESFileMetadata *dropboxFile;

- (id)initWithDropboxFile:(DBFILESFileMetadata*)dropboxFile;

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *filePath))success
                              failure:(void (^)(NSString *errorMessage))failure;

@end
