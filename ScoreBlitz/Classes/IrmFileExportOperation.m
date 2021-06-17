//
//  IrmFileExportOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.03.15.
//
//

#import "IrmFileExportOperation.h"
#import "ScoreBlitzAppDelegate.h"
#import "ImportExportManager.h"
#import "ZKFileArchive.h"
#import "Score.h"

@implementation IrmFileExportOperation

#pragma mark - NSOperation Interface

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled] || self.score == nil)
    {
        // Must move the operation to the finished state if it is canceled.
        [self finishOperation];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.managedObjectContext.parentContext = UIAppDelegate.managedObjectContext;
    self.managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    
    [self exportIrmFile];
}

#pragma mark - Export

- (void)exportIrmFile
{
    NSError *error = nil;
    NSString *exportDirectory = [self exportDirectoryPath];
    
    // create score data
    ImportExportManager *ieManager = [[ImportExportManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    NSData *scoreData;
    switch (kCurrentDataVersion) {
        case DataVersion1:
            scoreData = [ieManager exportScoreV1:self.score withAnnotations:self.withAnnotations];
            break;
            
        case DataVersion2:
            scoreData = [ieManager exportScoreV2:self.score withAnnotations:self.withAnnotations];
            break;
            
        case DataVersion3:
            scoreData = [ieManager exportScoreV3:self.score withAnnotations:self.withAnnotations];
            break;
            
        default: {
            self.errorMessage = MyLocalizedString(@"wrongVersionAlertViewTitle", nil);
            self.failure = YES;
            [self finishOperation]; // automatically fires completion block

            break;
        }
    }
    
    // create stable filename
    NSString *scoreFileName = [self createFileName];
    
    // create plist for data version
    NSString *plistFilePath = [exportDirectory stringByAppendingPathComponent:@"version.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:plistFilePath error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"exportScore: Error while deleting old data file: %@, %@", error, [error userInfo]);
#endif
            self.errorMessage = [error localizedDescription];
            self.failure = YES;
            [self finishOperation]; // automatically fires completion block
        }
    }
    [[NSString stringWithFormat:@"%d", kCurrentDataVersion] writeToFile:plistFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"exportScore: Error while creating plist file: %@, %@", error, [error userInfo]);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation]; // automatically fires completion block
    }
    
    // create score data file
    NSString *dataFilePath = [exportDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", scoreFileName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dataFilePath error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"exportScore: Error while deleting old data file: %@, %@", error, [error userInfo]);
#endif
            self.errorMessage = [error localizedDescription];
            self.failure = YES;
            [self finishOperation]; // automatically fires completion block
        }
    }
    [[NSFileManager defaultManager] createFileAtPath:dataFilePath contents:scoreData attributes:nil];
    
    // wrap up the dictionary data and the pdf file into a zip file
    NSString *zipFilePath = [exportDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", scoreFileName, kScoreBlitzFileExtension]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath]) {
#ifdef DEBUG
        NSLog(@"%s: file exists at path: %@", __func__, zipFilePath);
#endif
        [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"%s: Error while deleting old zip file: %@, %@", __func__, error, [error userInfo]);
#endif
            self.errorMessage = [error localizedDescription];
            self.failure = YES;
            [self finishOperation]; // automatically fires completion block
        }
    }
    
    ZKFileArchive *zkFileArchive = [ZKFileArchive archiveWithArchivePath:zipFilePath];
    [zkFileArchive deflateFile:dataFilePath relativeToPath:[dataFilePath stringByDeletingLastPathComponent] usingResourceFork:NO];
    [zkFileArchive deflateFile:[self.score pdfFilePath] relativeToPath:[[self.score pdfFilePath] stringByDeletingLastPathComponent] usingResourceFork:NO];
    [zkFileArchive deflateFile:plistFilePath relativeToPath:[dataFilePath stringByDeletingLastPathComponent] usingResourceFork:NO];
    
    // remove temporary files
    [[NSFileManager defaultManager] removeItemAtPath:dataFilePath error:&error];
    
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"exportScore: Error while deleting data file: %@, %@", error, [error userInfo]);
#endif
        error = nil;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:plistFilePath error:&error];
    
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"exportScore: Error while deleting data file: %@, %@", error, [error userInfo]);
#endif
    }
    
    self.exportFilePath = zipFilePath;
    [self finishOperation]; // automatically fires completion block    
}

@end
