
//
//  ScoreManager.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import "ScoreManager.h"
#import "NSString+Digest.h"
#import "CentralViewController.h"
#import "ScoreBlitzAppDelegate.h"
#import "Score.h"
#import "Set.h"
#import "SetListEntry.h"
#import "Page.h"
#import "RecentScoreList.h"
#import "RecentScoreListEntry.h"
#import "RecentSetList.h"
#import "RecentSetListEntry.h"
#import "UIImage+Resize.h"
#import "ZKFileArchive.h"
#import "Repeat.h"
#import "Measure.h"
#import "Jump.h"
#import "SleepManager.h"
#import "SignAnnotation.h"
#import "PrintSignAnnotation.h"
#include <sys/xattr.h>

@interface ScoreManager () 
#pragma mark Private Properties
@property (nonatomic, strong) NSManagedObjectContext *threadedContext;

@end

@implementation ScoreManager

@synthesize context_ , allScoresRequest_, allSetsRequest_;

@synthesize cachedFilePath, documentsDirectoryPath, localFileManager, sourceApplicationForFile;
@synthesize inboxDirectoryPath;
@synthesize importDirectoryPath;

#pragma mark -
#pragma mark Methods ensuring singleton status


+ (ScoreManager *)sharedInstance {
    static ScoreManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		// init core date stuff
		context_ = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
				
		allScoresRequest_ = [[NSFetchRequest alloc] init];
		[allScoresRequest_ setEntity:[Score entityDescription]];
		
		allSetsRequest_ = [[NSFetchRequest alloc] init];
		[allSetsRequest_ setEntity:[Set entityDescription]];
	
		appDelegate =  (ScoreBlitzAppDelegate *) [[UIApplication sharedApplication] delegate];
		documentsDirectoryPath = [[appDelegate applicationDocumentsDirectory] path];
        inboxDirectoryPath = [[[appDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"Inbox"];
        importDirectoryPath = [[appDelegate applicationImportDirectory] path];
		
		localFileManager = [[NSFileManager alloc] init];
		[localFileManager setDelegate:self];
        
        if (![localFileManager fileExistsAtPath:importDirectoryPath]) {
            NSError *error = nil;
            [localFileManager createDirectoryAtPath:importDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (nil != error) {
#ifdef DEBUG
                NSLog(@"%s: %@: %@", __func__, error, [error userInfo]);
#endif        
            }
        }
	}
	return self;
}

#pragma mark -
#pragma mark Startup


- (BOOL)handleOpenURL:(NSURL*)url 
{
    NSString *pathExtension = [[url path] pathExtension];
    
    if ((pathExtension != nil) && ([kPdfFileExtensions containsObject:pathExtension] || [kIrmFileExtensions containsObject:pathExtension])) {
        return YES;
    } else {
        return NO;
    }
}


- (void)launchedWithUrl:(NSURL *)fileURL sourceApplication:(NSString *)sourceApplication
{
   self.cachedFilePath = [fileURL path];
   self.sourceApplicationForFile = sourceApplication;
#ifdef DEBUG
	NSLog(@"launchedWithUrl: cachedPdfPath: %@", self.cachedFilePath);
#endif
}

- (void)copySampleData
{
    // Sample content had to marked as "do not backup" so it needs to be recreated in case it was deleted
#if !CopySampleData
    if (CopySamplePdfsToDocumentsDirectory) {
        [self copySamplePdfs];
    } else {
        [self copyTheShit];
    }
#endif
}


- (void)removeFileFromInbox:(NSString*)file
{
    NSError *error = nil;
    
    if ([self.localFileManager fileExistsAtPath:file]) {
        [self.localFileManager removeItemAtPath:file error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"removeFileFromInbox: Error while deleting file from inbox: %@, %@", error, [error userInfo]);
#endif
        }
    }

}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

#pragma mark -
#pragma mark filemanager delegate


- (BOOL)fileManager:(NSFileManager *)fileManager shouldMoveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
	return YES;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
	return YES;
}


#pragma mark -
#pragma mark Database Operations


- (void)deleteScore:(Score *)score
{
    // delete score directory
    NSError *error = nil;
    if ([self.localFileManager fileExistsAtPath:[score scoreDirectory]]) {
        [self.localFileManager removeItemAtPath:[score scoreDirectory] error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"deleteScore: Error removing score directory: %@, %@", error, [error userInfo]);
#endif
        }
    }
    
	[context_ deleteObject:score];
	[self saveTheFuckingContext];
}

- (Set *)addNewSet:(NSString *)setName
{
	// create new Set
	Set *newSet = (Set *) [[NSManagedObject alloc] initWithEntity:[Set entityDescription]
								   insertIntoManagedObjectContext:context_];
	newSet.name = setName;
		
	// save entry to db
	[self saveTheFuckingContext];
	return newSet;
}

- (void)removeSet:(Set *)set
{
	//delete from context
	[context_ deleteObject:set];
	[self saveTheFuckingContext];
}

- (void)changeSetName:(Set *)set newName:(NSString *)newName
{
	set.name = newName;
	[self saveTheFuckingContext];
}

- (SetListEntry *)addSetListEntryToSet:(Set *)set score:(Score *)score
{
	// get rank for new Entry
	NSNumber *newRank = [NSNumber numberWithInteger:[set.setListEntries count]];
		
	//create new setListEntry	
	SetListEntry *newSetListEntry = (SetListEntry *) [[NSManagedObject alloc] initWithEntity:[SetListEntry entityDescription]
															  insertIntoManagedObjectContext:context_];
	newSetListEntry.rank = newRank;
   newSetListEntry.setList = set;
   newSetListEntry.score = score;
	
	// save entry to db
	[self saveTheFuckingContext];
	return newSetListEntry;
}

- (void)removeSetListEntry:(SetListEntry *)setListEntry
{
	[context_ deleteObject:setListEntry];
	[self saveTheFuckingContext];
}

- (void)moveSetListEntry:(SetListEntry *)setListEntry fromIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSMutableArray *setListEntries = [NSMutableArray arrayWithArray:[setListEntry.setList orderedSetListEntriesAsc]];
    
    [setListEntries removeObjectAtIndex:oldIndex];
    [setListEntries insertObject:setListEntry atIndex:newIndex];
    
    for (SetListEntry *theSetListEntry in setListEntries) {
        theSetListEntry.rank = [NSNumber numberWithInteger:[setListEntries indexOfObject:theSetListEntry]];
    }
       
	[self saveTheFuckingContext];
}

- (NSMutableArray *)allScores
{
	NSError *error = nil;
	
	NSMutableArray *allScores = [NSMutableArray arrayWithArray:[context_ executeFetchRequest:allScoresRequest_ error:&error]];
	
	if (nil != error) {
#ifdef DEBUG        
		NSLog(@"ScoreManager: allScores Error loading Scores from Core Data Store: %@, %@", error, [error userInfo]);
#endif        
		return nil;
	} else {
		return allScores;
	}
}

- (NSMutableArray *)allSets
{
	NSError *error = nil;
	
	NSMutableArray *allSets = [NSMutableArray arrayWithArray:[context_ executeFetchRequest:allSetsRequest_ error:&error]];
	
	if (nil != error) {
#ifdef DEBUG        
		NSLog(@"ScoreManager: allSets Error loading Sets from Core Data Store: %@, %@", error, [error userInfo]);
#endif        
		return nil;
	} else {
		return allSets;
	}
}

- (RecentScoreList *)recentScoreList
{
	NSError *error = nil;
	RecentScoreList *newRecentScoreList  = nil;

	NSFetchRequest *recentScoreListRequest = [[NSFetchRequest alloc] init];
	[recentScoreListRequest setEntity:[RecentScoreList entityDescription]];
	NSArray *resultOfRequest = [NSArray arrayWithArray:[context_ executeFetchRequest:recentScoreListRequest error:&error]];
	 
	if ([resultOfRequest count] > 0)
	{
		newRecentScoreList  = [resultOfRequest objectAtIndex:0];
	}

	if (nil != error) {
#ifdef DEBUG        
		NSLog(@"ScoreManager: recentScoreList Error loading List from Core Data Store: %@, %@", error, [error userInfo]);
#endif        
		return nil;
	} else {
		return newRecentScoreList;
	}
}

- (void)pushScoreToRecentList:(Score *)newScore
{
	RecentScoreList *recentScoreList = [self recentScoreList];
	NSUInteger oldIndex = -1;
	RecentScoreListEntry *oldEntry = nil;
	BOOL identicalScoreFound = NO;
	
	if (nil == recentScoreList) {
		// create new recentscorelist
		RecentScoreList *newRecentScoreList = (RecentScoreList *) [[NSManagedObject alloc] initWithEntity:[RecentScoreList entityDescription]
																				insertIntoManagedObjectContext:context_];
		//create new recentScoreListEntry	
		RecentScoreListEntry *newRecentScoreListEntry = (RecentScoreListEntry *) [[NSManagedObject alloc] initWithEntity:[RecentScoreListEntry entityDescription]
																						  insertIntoManagedObjectContext:context_];
		newRecentScoreListEntry.rank = [NSNumber numberWithInt:0];	
		newRecentScoreListEntry.score = newScore;
		newRecentScoreListEntry.recentScoreList = newRecentScoreList;
		[self saveTheFuckingContext];
	} else {
      // first check if there are entries in the recent list, if yes skip the dupe check below
      if ([recentScoreList.recentScoreListEntries count] > 0) {
  		// check if the first listentry is for the new score, if yes do nothing because it is already the first entry
         if (![newScore isEqual:[[[recentScoreList orderedRecentScoreListEntriesAsc] objectAtIndex:0] score]]) {
            // check if the list already contains an entry with the new score
            NSMutableArray *recentScoreListEntries = [NSMutableArray arrayWithArray:[recentScoreList orderedRecentScoreListEntriesAsc]];
            for (RecentScoreListEntry *recentScoreListEntry in recentScoreListEntries)
            {
               if ([recentScoreListEntry.score isEqual:newScore])
               {
                  oldIndex = [recentScoreListEntries indexOfObject:recentScoreListEntry];
                  oldEntry = recentScoreListEntry;
                  identicalScoreFound = YES;
               }
            }
            if (identicalScoreFound) {
               // rearrange the entries
               //NSLog(@"ScoreManager: pushScoreToRecentList: RecentScoreListEntries before rearrange %@", recentScoreListEntries);
               [recentScoreListEntries removeObjectAtIndex:oldIndex];
               [recentScoreListEntries insertObject:oldEntry atIndex:0];
               
               for (RecentScoreListEntry *entry in recentScoreListEntries)
               {
                  entry.rank = [NSNumber numberWithInteger:[recentScoreListEntries indexOfObject:entry]];
                  //NSLog(@"ScoreManager: pushScoreToRecentList: RecentScoreList %@", entry);
               }
               [self saveTheFuckingContext];
               //NSLog(@"ScoreManager: pushScoreToRecentList: RecentScoreListEntries %@", recentScoreListEntries);
            } else { // if no identical score found add new entry
               if ([recentScoreList.recentScoreListEntries count] == kMaxRecentScores) {
                  // delete last entry recentScoreListEntry
                  [context_ deleteObject:[[recentScoreList orderedRecentScoreListEntriesAsc] lastObject]];
               }
               
               // increment rank of the existing entries
               [recentScoreList.recentScoreListEntries makeObjectsPerformSelector:@selector(incRank)];
               //NSLog(@"ScoreManager: pushScoreToRecentList: RecentScoreList before add %@", [recentScoreList orderedRecentScoreListEntriesAsc]);							
               //create new recentScoreListEntry	
               RecentScoreListEntry *newRecentScoreListEntry = (RecentScoreListEntry *) [[NSManagedObject alloc] initWithEntity:[RecentScoreListEntry entityDescription]
                                                                             insertIntoManagedObjectContext:context_];
               newRecentScoreListEntry.rank = [NSNumber numberWithInt:0];	
               newRecentScoreListEntry.score = newScore;
               newRecentScoreListEntry.recentScoreList = recentScoreList;
               //NSLog(@"ScoreManager: pushScoreToRecentList: newRecentScoreListEntry %@", newRecentScoreListEntry.score.name);
               [self saveTheFuckingContext];
               //NSLog(@"ScoreManager: pushScoreToRecentList: RecentScoreList after add %@", [recentScoreList orderedRecentScoreListEntriesAsc]);
            }
         }
      } else {
         //if an empty recentScoreList exists create new recentScoreListEntry	and add to list
         RecentScoreListEntry *newRecentScoreListEntry = (RecentScoreListEntry *) [[NSManagedObject alloc] initWithEntity:[RecentScoreListEntry entityDescription]
                                                                                           insertIntoManagedObjectContext:context_];
         newRecentScoreListEntry.rank = [NSNumber numberWithInt:0];	
         newRecentScoreListEntry.score = newScore;
         newRecentScoreListEntry.recentScoreList = recentScoreList;
         //NSLog(@"ScoreManager: pushScoreToRecentList: newRecentScoreListEntry %@", newRecentScoreListEntry.score.name);
         [self saveTheFuckingContext];
         //NSLog(@"ScoreManager: pushScoreToRecentList: RecentScoreList after add %@", [recentScoreList orderedRecentScoreListEntriesAsc]);
      }
	}
}

- (void)deleteScoreFromRecentList:(Score *)scoreToDelete
{
    RecentScoreList *recentScoreList = [self recentScoreList];
    RecentScoreListEntry *entryToDelete = nil;
    
    for (RecentScoreListEntry *recentScoreListEntry in recentScoreList.recentScoreListEntries) {
        if ([scoreToDelete isEqual:recentScoreListEntry.score]) {
            entryToDelete = recentScoreListEntry;
        }
    }
    if (nil != entryToDelete) {
        [context_ deleteObject:entryToDelete];
        [self saveTheFuckingContext];
    }
}

- (RecentSetList *)recentSetList
{
	NSError *error = nil;
	RecentSetList *newRecentSetList  = nil;
	
	NSFetchRequest *recentSetListRequest = [[NSFetchRequest alloc] init];
	[recentSetListRequest setEntity:[RecentSetList entityDescription]];
	NSArray *resultOfRequest = [NSArray arrayWithArray:[context_ executeFetchRequest:recentSetListRequest error:&error]];
	
	if ([resultOfRequest count] > 0)
	{
		newRecentSetList  = [resultOfRequest objectAtIndex:0];
	}

	if (nil != error) {
#ifdef DEBUG        
		NSLog(@"ScoreManager: recentSetList Error loading List from Core Data Store: %@, %@", error, [error userInfo]);
#endif        
		return nil;
	} else {
		return newRecentSetList;
	}
}

- (void)pushSetToRecentList:(Set *)newSet
{
	RecentSetList *recentSetList = [self recentSetList];
	NSUInteger oldIndex = -1;
	RecentSetListEntry *oldEntry = nil;
	BOOL identicalSetFound = NO;
	
	if (nil == recentSetList) {
		// create new recentscorelist
		RecentSetList *newRecentSetList = (RecentSetList *) [[NSManagedObject alloc] initWithEntity:[RecentSetList entityDescription]
																		   insertIntoManagedObjectContext:context_];
		//create new recentScoreListEntry	
		RecentSetListEntry *newRecentSetListEntry = (RecentSetListEntry *) [[NSManagedObject alloc] initWithEntity:[RecentSetListEntry entityDescription]
																						  insertIntoManagedObjectContext:context_];
		newRecentSetListEntry.rank = [NSNumber numberWithInt:0];	
		newRecentSetListEntry.setList = newSet;
		newRecentSetListEntry.recentSetList = newRecentSetList;
		[self saveTheFuckingContext];
	} else {
      // first check if there are entries in the recent list, if yes skip the dupe check below
      if ([recentSetList.recentSetListEntries count] > 0) {
         // first check if the first listentry is for the new score, if yes do nothing because it is already the first entry
         if (![newSet isEqual:[[[recentSetList orderedRecentSetListEntriesAsc] objectAtIndex:0] setList]]) {
            // check if the list already contains an entry with the new score
            NSMutableArray *recentSetListEntries = [NSMutableArray arrayWithArray:[recentSetList orderedRecentSetListEntriesAsc]];
            for (RecentSetListEntry *recentSetListEntry in recentSetListEntries)
            {
               if ([recentSetListEntry.setList isEqual:newSet])
               {
                  oldIndex = [recentSetListEntries indexOfObject:recentSetListEntry];
                  oldEntry = recentSetListEntry;
                  identicalSetFound = YES;
               }
            }
            
            if (identicalSetFound) {
               // rearrange the entries
               [recentSetListEntries removeObjectAtIndex:oldIndex];
               [recentSetListEntries insertObject:oldEntry atIndex:0];
               
               for (RecentSetListEntry *recentSetListEntry in recentSetListEntries)
               {
                  recentSetListEntry.rank = [NSNumber numberWithInteger:[recentSetListEntries indexOfObject:recentSetListEntry]];
               }
               [self saveTheFuckingContext];
            } else { // if no identical score found add new entry
               if ([recentSetList.recentSetListEntries count] == kMaxRecentSets) {
                  // delete last entry recentScoreListEntry
                  [context_ deleteObject:[[recentSetList orderedRecentSetListEntriesAsc] lastObject]];
               }
               
               // increment rank of the existing entries
               [recentSetList.recentSetListEntries makeObjectsPerformSelector:@selector(incRank)];
                
               //create new recentScoreListEntry	
               RecentSetListEntry *newRecentSetListEntry = (RecentSetListEntry *) [[NSManagedObject alloc] initWithEntity:[RecentSetListEntry entityDescription]
                                                                             insertIntoManagedObjectContext:context_];
               newRecentSetListEntry.rank = [NSNumber numberWithInt:0];	
               newRecentSetListEntry.setList = newSet;
               newRecentSetListEntry.recentSetList = recentSetList;

               [self saveTheFuckingContext];

            }
         }
      } else {
         //if an empty recentSetList exists create new recentScoreListEntry	and add to list
         RecentSetListEntry *newRecentSetListEntry = (RecentSetListEntry *) [[NSManagedObject alloc] initWithEntity:[RecentSetListEntry entityDescription]
                                                                                     insertIntoManagedObjectContext:context_];
         newRecentSetListEntry.rank = [NSNumber numberWithInt:0];	
         newRecentSetListEntry.setList = newSet;
         newRecentSetListEntry.recentSetList = recentSetList;
          
         [self saveTheFuckingContext];
      }
	}
}

- (void)deleteSetFromRecentList:(Set *)setToDelete
{
    RecentSetList *recentSetList = [self recentSetList];
    RecentSetListEntry *entryToDelete = nil;
    
    for (RecentSetListEntry *recentSetListEntry in recentSetList.recentSetListEntries) {
        if ([setToDelete isEqual:recentSetListEntry.setList]) {
            entryToDelete = recentSetListEntry;
        }
    }
    if (nil != entryToDelete) {
        [context_ deleteObject:entryToDelete];
        [self saveTheFuckingContext];
    }
}


- (void)tutorials
{
	// spit out the tutorials objects
}


- (void)saveTheFuckingContext
{	
	[appDelegate saveContext];
}

#pragma mark -
#pragma mark functions for development purposes

- (void)copyTheShit
{
	NSArray *arrayOfShitPaths = [NSBundle pathsForResourcesOfType:kPdfFileExtension inDirectory:[[NSBundle mainBundle] resourcePath]];

	for (NSString *oldPdfPath in arrayOfShitPaths)
	{
        NSString *newPdfPath = [self.documentsDirectoryPath stringByAppendingPathComponent:[oldPdfPath lastPathComponent]];
        NSError *error = nil;
        
        if (![self.localFileManager fileExistsAtPath:newPdfPath]) {
            [self.localFileManager copyItemAtPath:oldPdfPath toPath:newPdfPath error:&error];
        }
        
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"movePdfToDocumentsDirectory: Error while copying pdf file to documents directory: %@, %@", error, [error userInfo]);
#endif
        }        
    }
}

- (NSString *)copyPdfToDocumentsDirectory:(NSString *)pdfPath
{
	NSError *error = nil;
	NSString *newPdfPath = [self.documentsDirectoryPath stringByAppendingPathComponent:[pdfPath lastPathComponent]];
	
    if ([self.localFileManager fileExistsAtPath:newPdfPath]) { // if file already exist in documents directory, rename and copy it
        NSString *fileName = [[pdfPath lastPathComponent] stringByDeletingPathExtension];
        
        int counter = 1;
        while ([self.localFileManager fileExistsAtPath:newPdfPath]) {
            newPdfPath = [[newPdfPath stringByDeletingLastPathComponent] 
                          stringByAppendingPathComponent:[fileName stringByAppendingString:[NSString stringWithFormat:@"(%d).pdf", counter]]];
            counter++;
        }
        [self.localFileManager copyItemAtPath:pdfPath toPath:newPdfPath error:&error];
    } else { // if it doesn't exist, just copy
        [self.localFileManager copyItemAtPath:pdfPath toPath:newPdfPath error:&error];
    }
    
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"movePdfToDocumentsDirectory: Error while copying pdf file to documents directory: %@, %@", error, [error userInfo]);
#endif
        error = nil;
        return nil;
    } else {
        // delete pdf in inbox directory
        if ([[[pdfPath stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:@"Inbox"]) {
            [self.localFileManager removeItemAtPath:pdfPath error:&error];
            
            if (nil != error) {
#ifdef DEBUG
                NSLog(@"movePdfToDocumentsDirectory: Error while deleting old pdf file in inbox: %@, %@", error, [error userInfo]);
#endif
                error = nil;
            } 
        }
        
        // return the new URL for the pdf
        return newPdfPath;
    }
}

- (void)copySamplePdfs
{
    // get the file paths
    NSArray *imageDirs = [[NSBundle mainBundle] pathsForResourcesOfType:nil 
                                                            inDirectory:kDefaultImageDirectory];
    for (NSString *imageDir in imageDirs) {
        NSArray *pdfPaths = [[NSBundle mainBundle] pathsForResourcesOfType:kPdfFileExtension
                                                               inDirectory:[kDefaultImageDirectory stringByAppendingPathComponent:[imageDir lastPathComponent]]];
        if ([pdfPaths count] > 0) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[Score entityDescription]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pdfFileName == %@", [[pdfPaths objectAtIndex:0] lastPathComponent]];
            [fetchRequest setPredicate:predicate];
            NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:NULL];
            if (0 == [fetchedObjects count]) {
                [self copyPdfToDocumentsDirectory:[pdfPaths objectAtIndex:0]];
            }
        } 
    }
}

#pragma mark - Core Data Utility Functions

- (NSArray *)allRepeatsForScore:(Score *)theScore
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Repeat entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startMeasure.page.score == %@ OR endMeasure.page.score == %@", theScore, theScore];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    
    return fetchedObjects;    
}

- (NSArray *)endRepeatsForScore:(Score *)theScore
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Repeat entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endMeasure.page.score == %@ AND startMeasure == nil", theScore];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    
    return fetchedObjects;    
}

- (NSArray *)zombieRepeats
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Repeat entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endMeasure == nil AND startMeasure == nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    
    return fetchedObjects;    
}

- (NSArray *)zombieJumps
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Jump entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"destinationMeasure == nil AND originMeasure == nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    
    return fetchedObjects;    
}


- (Measure *)targetMeasureForScore:(Score *)theScore andKeyPath:(NSString *)measureKeyPath
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Measure entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"page.score == %@ AND %K == %@", theScore, measureKeyPath, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }else if ([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}


- (NSArray *)jumpsForScore:(Score *)theScore andJumpTypes:(NSArray *)types
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Jump entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(originMeasure.page.score == %@ OR destinationMeasure.page.score == %@) AND jumpType IN %@", 
                              theScore, theScore, types];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif  
    }
    
    return fetchedObjects;
}

- (Jump *)jumpForScore:(Score *)theScore andJumpType:(APJumpType)jumpType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Jump entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(originMeasure.page.score == %@ OR destinationMeasure.page.score == %@) AND jumpType == %@", 
                              theScore, theScore, [NSNumber numberWithInt:jumpType]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif  
    }else if ([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)allJumpsForScore:(Score *)theScore
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Jump entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originMeasure.page.score == %@ OR destinationMeasure.page.score == %@", 
                              theScore, theScore];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif  
    }
    
    return fetchedObjects;
}

- (NSArray *)invalidJumps
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Jump entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"destinationMeasure == nil OR originMeasure == nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    
    return fetchedObjects;    
}



- (NSArray *)invalidRepeats
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[Repeat entityDescription]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endMeasure == nil OR startMeasure == nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context_ executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    
    return fetchedObjects;    
}


- (void)matchDanglingRepeatsForScore:(Score *)theScore
{
    NSArray *sortedMeasures = [theScore measuresSortedByCoordinates];
    
    for (Repeat *aRepeat in [self endRepeatsForScore:theScore]) {
        // Go look for matching start measure
        NSInteger endMeasureIndex = [sortedMeasures indexOfObject:aRepeat.endMeasure];
        NSArray *previousMeasures = [sortedMeasures subarrayWithRange:NSMakeRange(0, endMeasureIndex + 1)]; // include repeat.endMeasure
        for (Measure *previousMeasure in [previousMeasures reverseObjectEnumerator]) {
            if (nil != previousMeasure.endRepeat && ![previousMeasure isEqual:aRepeat.endMeasure]) {
                // Disallow nested repeats
                break;
            }else if (nil != previousMeasure.startRepeat && nil == previousMeasure.startRepeat.endMeasure) {
                aRepeat.startMeasure = previousMeasure;
            }
        }
    }    
}

#pragma mark - Utilities

- (NSString *)sleepIdentifier
{
    return @"ScoreManager";
}


@end
