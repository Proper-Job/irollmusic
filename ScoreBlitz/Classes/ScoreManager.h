//
//  ScoreManager.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class ScoreBlitzAppDelegate;
@class Score;
@class Set;
@class SetListEntry;
@class RecentScoreList;
@class RecentSetList;
@class Page;
@class Jump;
@class Measure;

@interface ScoreManager : NSObject <UIAlertViewDelegate, NSFileManagerDelegate> {
	ScoreBlitzAppDelegate *appDelegate;
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *context_;
@property (nonatomic, strong, readonly) NSFetchRequest *allScoresRequest_, *allSetsRequest_;
@property (nonatomic, copy) NSString *cachedFilePath, *documentsDirectoryPath, *sourceApplicationForFile, *inboxDirectoryPath, *importDirectoryPath;
@property (nonatomic, strong) NSFileManager *localFileManager;

+ (ScoreManager *)sharedInstance;

- (BOOL)handleOpenURL:(NSURL*)url;
- (void)launchedWithUrl:(NSURL *)fileURL sourceApplication:(NSString *)sourceApplication;
- (void)copySampleData;

- (void)removeFileFromInbox:(NSString*)file;

- (void)deleteScore:(Score *)score;
- (Set *)addNewSet:(NSString *)setName;
- (void)removeSet:(Set *)set;
- (void)changeSetName:(Set *)set newName:(NSString *)newName;

- (SetListEntry *)addSetListEntryToSet:(Set *)set score:(Score *)score;
- (void)removeSetListEntry:(SetListEntry *)setListEntry;
- (void)moveSetListEntry:(SetListEntry *)setListEntry fromIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex;

- (void)tutorials;
- (NSString *)sleepIdentifier;

- (NSMutableArray *)allScores;
- (NSMutableArray *)allSets;

- (RecentScoreList *)recentScoreList;
- (void)pushScoreToRecentList:(Score *)newScore;
- (void)deleteScoreFromRecentList:(Score *)scoreToDelete;
- (RecentSetList *)recentSetList;
- (void)pushSetToRecentList:(Set *)newSet;
- (void)deleteSetFromRecentList:(Set *)setToDelete;

- (void)saveTheFuckingContext;

- (NSString *)copyPdfToDocumentsDirectory:(NSString *)pdfPath;
- (void)copyTheShit;
- (void)copySamplePdfs;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

- (NSArray *)allRepeatsForScore:(Score *)theScore;
- (NSArray *)endRepeatsForScore:(Score *)theScore;
- (NSArray *)zombieRepeats;
- (NSArray *)zombieJumps;
- (Measure *)targetMeasureForScore:(Score *)theScore andKeyPath:(NSString *)measureKeyPath;
- (NSArray *)jumpsForScore:(Score *)theScore andJumpTypes:(NSArray *)types;
- (Jump *)jumpForScore:(Score *)theScore andJumpType:(APJumpType)jumpType;
- (NSArray *)allJumpsForScore:(Score *)theScore;
- (NSArray *)invalidJumps;
- (NSArray *)invalidRepeats;
- (void)matchDanglingRepeatsForScore:(Score *)theScore;

@end
