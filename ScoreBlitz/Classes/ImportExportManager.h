//
//  ImportExportManager.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Score;

@interface ImportExportManager : NSObject {

}

@property (nonatomic, strong) NSManagedObjectContext *_context;
@property (nonatomic, strong) NSData *_data;
@property (nonatomic, strong) Score *_score;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

- (Score*)importDataV1:(NSData*)data;
- (NSData*)exportScoreV1:(Score*)score withAnnotations:(BOOL)withAnnotations;

- (Score*)importDataV2:(NSData*)data;
- (NSData*)exportScoreV2:(Score*)score withAnnotations:(BOOL)withAnnotations;

- (Score*)importDataV3:(NSData*)data;
- (NSData*)exportScoreV3:(Score*)score withAnnotations:(BOOL)withAnnotations;

#define kScoreDataV1ArchiveKey @"ScoreDataV1Archive"

@end
