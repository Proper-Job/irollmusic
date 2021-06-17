//
//  DropboxTransferAgent.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransferFile.h"

@interface DropboxTransferManager : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue, *downloadOperationQueue, *uploadOperationQueue;
@property (nonatomic, assign) NSInteger totalOperations, completedOperations;

+ (DropboxTransferManager *)sharedInstance;

- (BOOL)isTransfering;

- (void)startTransferwithInboxFiles:(NSMutableArray*)filesForInbox andOutboxFiles:(NSMutableArray*)filesForOutbox;
- (void)cancelTransfer;
- (NSString *)sleepIdentifier;

@end
