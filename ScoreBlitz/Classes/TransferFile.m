//
//  TransferFile.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TransferFile.h"

@implementation TransferFile

- (id)initWithScore:(Score*)newScore
{
    self = [super init];
    if (self) {
        self.score = newScore;
        self.fileName = newScore.name;
        
        NSString *pdfPath = [newScore pdfFilePath];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:pdfPath error:nil];
        self.fileSize = (double)[fileAttributes fileSize] / 1024;
        self.iRollMusicFile = YES;
        self.annotations = YES;
        self.transferCompleted = NO;
        self.transferCanceled = NO;
        self.transferFailed = NO;
    }
    return self;
}

- (id)initWithDropBoxFile:(DBFILESFileMetadata*)newDbMetadata
{
    self = [super init];
    if (self) {
        self.dropboxFile = newDbMetadata;
        self.fileName = newDbMetadata.name;
        
       
        self.fileSize = (double)([newDbMetadata.size doubleValue] / 1024.0);
        self.iRollMusicFile = NO;
        self.annotations = NO;
        self.transferCompleted = NO;
        self.transferCanceled = NO;
        self.transferFailed = NO;
    }
    return self;    
}

- (void)resetTransferStatus
{
    self.transferCompleted = NO;
    self.transferCanceled = NO;
    self.transferFailed = NO;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    TransferFile *newTransferFile = [[[self class] allocWithZone:zone] init];
    newTransferFile.fileName = self.fileName;
    newTransferFile.score = self.score;
    newTransferFile.dropboxFile = self.dropboxFile;
    newTransferFile.iRollMusicFile = self.iRollMusicFile;
    newTransferFile.annotations = self.annotations;
    newTransferFile.transferCompleted = self.transferCompleted;
    newTransferFile.transferCanceled = self.transferCanceled;
    newTransferFile.transferFailed = self.transferFailed;
    newTransferFile.fileSize = self.fileSize;
    return newTransferFile;
}

#pragma mark -
#pragma mark status strings

- (NSString*)doneString
{
    return [NSString stringWithFormat:@"%.02f MB - %@", self.fileSize/1024, MyLocalizedString(@"buttonDone", nil)];
}

- (NSString*)canceledString
{
    return MyLocalizedString(@"transferCanceledText", nil);
}

- (NSString*)failedString
{
    return MyLocalizedString(@"transferFailedText", nil);
}


#pragma mark - Notification Sending

- (void)operationSuccess
{
    self.transferCompleted = YES;
    self.transferFailed = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTransferSuccess object:self];
}

- (void)operationFailed:(NSString*)errorMessage
{
    self.transferCompleted = NO;
    self.transferFailed = YES;
    if (errorMessage == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTransferDidFail object:self];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:kTransferDidFail
                                                                     object:self
                                                                   userInfo:@{kTransferDidFailMessage: errorMessage}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)operationProgress:(CGFloat)progress
{
    NSNumber *progressNumber = [NSNumber numberWithFloat:progress];
    NSNotification *notification = [NSNotification notificationWithName:kTransferFileProgressDidChange
                                                                 object:self
                                                               userInfo:@{kTransferFileProgressDidChangeValue: progressNumber}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end
