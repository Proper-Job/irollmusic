//
//  TransferFile.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Score.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface TransferFile : NSObject <NSCopying>

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) DBFILESFileMetadata *dropboxFile;

@property (nonatomic, assign) BOOL iRollMusicFile, transferCompleted, transferFailed, transferCanceled, annotations;
@property (nonatomic, assign) double fileSize; // in kilobytes

- (id)initWithScore:(Score*)newScore;
- (id)initWithDropBoxFile:(DBFILESFileMetadata*)newDbMetadata;

- (void)resetTransferStatus;

- (NSString*)doneString;
- (NSString*)canceledString;
- (NSString*)failedString;

- (void)operationSuccess;
- (void)operationFailed:(NSString*)errorMessage;
- (void)operationProgress:(CGFloat)progress;

@end


