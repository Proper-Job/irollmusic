//
//  DropboxTransferAgent.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DropboxTransferManager.h"
#import "ScoreBlitzAppDelegate.h"
#import "SleepManager.h"
#import "DropboxFileDownloadOperation.h"
#import "DropboxFileUploadOperation.h"
#import "PdfFileImportOperation.h"
#import "PdfFileExportOperation.h"
#import "IrmFileImportOperation.h"
#import "IrmFileExportOperation.h"

@implementation DropboxTransferManager

+ (DropboxTransferManager *)sharedInstance
{
    static DropboxTransferManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.downloadOperationQueue = [[NSOperationQueue alloc] init];
        self.downloadOperationQueue.maxConcurrentOperationCount = 3;

        self.uploadOperationQueue = [[NSOperationQueue alloc] init];
        self.uploadOperationQueue.maxConcurrentOperationCount = 3;

        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

- (BOOL)isTransfering
{
    if (self.operationQueue.operationCount > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startTransferwithInboxFiles:(NSMutableArray*)filesForInbox andOutboxFiles:(NSMutableArray*)filesForOutbox
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDropboxTransferManagerDidStartFileTransfer object:nil];
    
    [self cancelTransfer];

    self.totalOperations = 0;
    self.completedOperations = 0;
    
    for (TransferFile *transferFile in filesForInbox) {
        if (!transferFile.transferCompleted && !transferFile.transferFailed && !transferFile.transferCanceled) {
            self.totalOperations++;
            
            DropboxFileDownloadOperation *dropboxFileDownloadOperation = [[DropboxFileDownloadOperation alloc] initWithDropboxFile:transferFile.dropboxFile];
            [dropboxFileDownloadOperation setCompletionBlockWithSuccess:^(NSString *filePath) {
                // Dowload Success
                NSString *pathExtension = [filePath pathExtension];
                
                if (pathExtension == nil) {
                    //failure
                    [transferFile operationFailed:nil];
                    self.completedOperations++;
                    [self checkForCompletion];
                    
                } else {
                    if ([kPdfFileExtensions containsObject:pathExtension]) {
                        PdfFileImportOperation *pdfFileImportOperation = [[PdfFileImportOperation alloc] initWithFilePath:filePath];
                        [pdfFileImportOperation setCompletionBlockWithSuccess:^(NSString *pdfFilePath) {
                            // PDF Import Success
                            [transferFile operationSuccess];
                            self.completedOperations++;
                            [self checkForCompletion];
                            
                        } failure:^(NSString *errorMessage) {
                            // PDF Import Failure
                            [transferFile operationFailed:errorMessage];
                            self.completedOperations++;
                            [self checkForCompletion];
                            
                        }];
                        [self.operationQueue addOperation:pdfFileImportOperation];
                    } else if ([kIrmFileExtensions containsObject:pathExtension]) {
                        IrmFileImportOperation *irmFileImportOperation = [[IrmFileImportOperation alloc] initWithFilePath:filePath];
                        [irmFileImportOperation setCompletionBlockWithSuccess:^(NSString *irmFilePath) {
                            // IRM Import Success
                            [transferFile operationSuccess];
                            self.completedOperations++;
                            [self checkForCompletion];
                            
                        } failure:^(NSString *errorMessage) {
                            // IRM Import Failure
                            [transferFile operationFailed:errorMessage];
                            self.completedOperations++;
                            [self checkForCompletion];
                            
                        }];
                        [self.operationQueue addOperation:irmFileImportOperation];
                    } else {
                        // File extension failure
                        [transferFile operationFailed:nil];
                        self.completedOperations++;
                        [self checkForCompletion];
                        
                    }
                }
                
            } failure:^(NSString *errorMessage) {
                // Download Failure
                [transferFile operationFailed:errorMessage];
                self.completedOperations++;
                [self checkForCompletion];
                
            }];
            [dropboxFileDownloadOperation setProgressBlock:^(CGFloat progress) {
                [transferFile operationProgress:progress];
            }];
            [self.downloadOperationQueue addOperation:dropboxFileDownloadOperation];
        }
    }
    
    for (TransferFile *transferFile in filesForOutbox) {
        if (!transferFile.transferCompleted && !transferFile.transferFailed && !transferFile.transferCanceled) {
            self.totalOperations++;
            
            if (transferFile.iRollMusicFile) {
                IrmFileExportOperation *irmFileExportOperation = [[IrmFileExportOperation alloc] initWithScore:transferFile.score];
                irmFileExportOperation.withAnnotations = transferFile.annotations;
                [irmFileExportOperation setCompletionBlockWithSuccess:^(NSString *exportFilePath) {
                    // IRM Export Success
                    DropboxFileUploadOperation *dropboxFileUploadOperation = [[DropboxFileUploadOperation alloc] initWithFilePath:exportFilePath];
                    [dropboxFileUploadOperation setCompletionBlockWithSuccess:^(NSString *uploadPath) {
                        // IRM Upload Succes
                        [transferFile operationSuccess];
                        self.completedOperations++;
                        [self checkForCompletion];

                    } failure:^(NSString *errorMessage) {
                        // IRM Upload Failure
                        [transferFile operationFailed:errorMessage];
                        self.completedOperations++;
                        [self checkForCompletion];

                    }];
                    [dropboxFileUploadOperation setProgressBlock:^(CGFloat progress) {
                        [transferFile operationProgress:progress];
                    }];
                    [self.operationQueue addOperation:dropboxFileUploadOperation];
                    
                } failure:^(NSString *exportFilePath) {
                    // IRM Export Failure
                    [transferFile operationFailed:nil];
                    self.completedOperations++;
                    [self checkForCompletion];

                }];
                [self.operationQueue addOperation:irmFileExportOperation];
            } else {
                PdfFileExportOperation *pdfFileExportOperation = [[PdfFileExportOperation alloc] initWithScore:transferFile.score];
                pdfFileExportOperation.withAnnotations = transferFile.annotations;
                [pdfFileExportOperation setCompletionBlockWithSuccess:^(NSString *exportFilePath) {
                    // PDF Export Success
                    DropboxFileUploadOperation *dropboxFileUploadOperation = [[DropboxFileUploadOperation alloc] initWithFilePath:exportFilePath];
                    [dropboxFileUploadOperation setCompletionBlockWithSuccess:^(NSString *uploadPath) {
                        // PDF Upload Success
                        [transferFile operationSuccess];
                        self.completedOperations++;
                        [self checkForCompletion];

                    } failure:^(NSString *errorMessage) {
                        // PDF Upload Failure
                        [transferFile operationFailed:errorMessage];
                        self.completedOperations++;
                        [self checkForCompletion];

                    }];
                    [dropboxFileUploadOperation setProgressBlock:^(CGFloat progress) {
                        [transferFile operationProgress:progress];
                    }];
                    [self.uploadOperationQueue addOperation: dropboxFileUploadOperation];
                    
                } failure:^(NSString *exportFilePath) {
                    // PDF Export Failure
                    [transferFile operationFailed:nil];
                    self.completedOperations++;
                    [self checkForCompletion];

                }];
                [self.operationQueue addOperation:pdfFileExportOperation];
            }
        }
    }
    
    [self checkForCompletion];
    [[SleepManager sharedInstance] addInsomniac:[self sleepIdentifier]];
}

#pragma mark - Operation Queue Management

- (void)cancelTransfer
{
    [self.downloadOperationQueue cancelAllOperations];
    [self.uploadOperationQueue cancelAllOperations];
    [self.operationQueue cancelAllOperations];
    [[SleepManager sharedInstance] removeInsomniac:[self sleepIdentifier]];
}

- (void)checkForCompletion
{
    if (self.totalOperations == self.completedOperations) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDropboxTransferManagerDidEndFileTransfer object:nil];
        [[SleepManager sharedInstance] removeInsomniac:[self sleepIdentifier]];
    }
}

- (NSString *)sleepIdentifier
{
    return @"DropboxTransferManager";
}

@end
