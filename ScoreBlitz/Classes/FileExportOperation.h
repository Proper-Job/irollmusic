//
//  FileExportOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.03.15.
//
//

#import <Foundation/Foundation.h>

@class Score, TransferFile;

@interface FileExportOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic, strong) TransferFile *transferFile;
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) NSString *exportFilePath, *errorMessage;

@property (nonatomic, assign) BOOL failure, withAnnotations;

- (id)initWithScore:(Score*)score;

- (void)setCompletionBlockWithSuccess:(void (^)(NSString *exportFilePath))success
                              failure:(void (^)(NSString *errorMessage))failure;
- (void)finishOperation;

- (NSString*)exportDirectoryPath;
- (NSString*)createFileName;

@end
