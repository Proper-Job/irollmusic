//
//  IrmFileImportOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 23.03.15.
//
//

#import "IrmFileImportOperation.h"
#import "ScoreBlitzAppDelegate.h"
#import "NSString+Digest.h"
#import "ZKFileArchive.h"
#import "ImportExportManager.h"
#import "Score.h"

@implementation IrmFileImportOperation

#pragma mark - NSOperation Interface

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled] || self.filePath == nil)
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
    
    [self importIrmFile];
}

#pragma mark - Import

- (void)importIrmFile
{
    // setup error variable
    NSError *error = nil;
    
    // generate secure tempdir name to exclude dupes
    NSString *importFileName = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
    NSDate *nowImport = [NSDate date];
    NSString *tempDir = [[importFileName stringByAppendingFormat:@"%ld", (long)[nowImport timeIntervalSince1970]]  SHA1];
    
    
    // create temp directories for file operations
    NSString *importDirectoryPath = [[UIAppDelegate applicationImportDirectory] path];
    NSString *tempDirectory = [importDirectoryPath stringByAppendingPathComponent:tempDir];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempDirectory]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempDirectory error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"importIrmFile: Error while deleting old tempDirectory: %@, %@", error, [error userInfo]);
#endif
            self.errorMessage = [error localizedDescription];
            self.failure = YES;
            [self finishOperation];
            return;
        }
    }
    NSString *expansionDirectory = [tempDirectory stringByAppendingPathComponent:@"expansionDir"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:expansionDirectory]) {
        [[NSFileManager defaultManager] removeItemAtPath:expansionDirectory error:&error];
        if (nil != error) {
#ifdef DEBUG
            NSLog(@"importIrmFile: Error while deleting old expansionDirectory: %@, %@", error, [error userInfo]);
#endif
            self.errorMessage = [error localizedDescription];
            self.failure = YES;
            [self finishOperation];
            return;
        }
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importIrmFile: error while creating tempDirectory: %@, error: %@", tempDirectory, error);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    
    // unzip file
    ZKFileArchive *zkFileArchiv = [ZKFileArchive archiveWithArchivePath:self.filePath];
    NSInteger success = [zkFileArchiv inflateToDirectory:expansionDirectory usingResourceFork:NO];
    if (!success) {
#ifdef DEBUG
        NSLog(@"Error deflating irm file");
#endif
        self.errorMessage = @"Error deflating irm file";
        self.failure = YES;
        [self finishOperation];
        return;
    }
    
    // get the file paths
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDirectory error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importIrmFile: error while getting contents of tempDirectory: %@, error: %@", tempDirectory, error);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    
#ifdef DEBUG
    NSLog(@"%s: contents of tempDirectory: %@", __func__, contents);
#endif
    
    // Check for data file path
    NSInteger dataFilePathIndex = [contents indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSString *)obj pathExtension] isEqualToString:kDataFileExtension];
    }];
    if (dataFilePathIndex == NSNotFound) {
#ifdef DEBUG
        NSLog(@"%s: Error: data file path not found", __func__);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    NSString *dataFilePath = [tempDirectory stringByAppendingPathComponent:[contents objectAtIndex:dataFilePathIndex]];
    
    // check for pdf file path
    NSInteger pdfFilePathIndex = [contents indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSString *pathExtension = [(NSString *)obj pathExtension];
        return [kPdfFileExtensions containsObject:pathExtension];
    }];
    if (pdfFilePathIndex == NSNotFound) {
#ifdef DEBUG
        NSLog(@"%s: Error: pdf file path not found", __func__);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    NSString *pdfFilePath = [tempDirectory stringByAppendingPathComponent:[contents objectAtIndex:pdfFilePathIndex]];
    
    // check for plis file path
    NSInteger plistFilePathIndex = [contents indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSString *)obj pathExtension] isEqualToString:kPlistFileExtension];
    }];
    if (plistFilePathIndex == NSNotFound) {
#ifdef DEBUG
        NSLog(@"%s: Error: plist file path not found", __func__);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    NSString *plistFilePath = [tempDirectory stringByAppendingPathComponent:[contents objectAtIndex:plistFilePathIndex]];
    
    // generate hash
    NSString *fileName = [[pdfFilePath lastPathComponent] stringByDeletingPathExtension];
    NSDate *now = [NSDate date];
    NSString *hashForFile = [[fileName stringByAppendingFormat:@"%d", (NSInteger)[now timeIntervalSince1970]]  SHA1];
    
    // determine version of score data
    NSString *versionString = [NSString stringWithContentsOfFile:plistFilePath encoding:NSUTF8StringEncoding error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importIrmFile: Error while importing version plist: %@, %@", error, [error userInfo]);
#endif
        self.errorMessage = [error localizedDescription];        
        self.failure = YES;
        [self finishOperation];
        return;
    }
    DataVersion version = [versionString intValue];
    
    // import score data from file
    ImportExportManager *ieManager = [[ImportExportManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    Score *newScore;
    switch (version) {
        case DataVersion1: {
            newScore = [ieManager importDataV1:[[NSFileManager defaultManager] contentsAtPath:dataFilePath]];
            break;
        }
            
        case DataVersion2: {
            newScore = [ieManager importDataV2:[[NSFileManager defaultManager] contentsAtPath:dataFilePath]];
            break;
        }
            
        case DataVersion3: {
            newScore = [ieManager importDataV3:[[NSFileManager defaultManager] contentsAtPath:dataFilePath]];
            break;
        }
            
        default: {
            self.errorMessage = MyLocalizedString(@"wrongVersionAlertViewTitle", nil);
            self.failure = YES;
            [self finishOperation];
            return;

            break;
        }
    }
    
    // get score name
    NSString *scoreName = newScore.name;
    if ([scoreName isEqualToString:[NSString string]] || (nil == scoreName)) {
        scoreName = [[[NSFileManager defaultManager] displayNameAtPath:pdfFilePath] stringByDeletingPathExtension];
    }
    newScore.name = scoreName;
    newScore.sha1Hash = hashForFile;
    
    // generate name for scoreDirectory and create directory
    NSString *scoreDirectoryPath = [newScore scoreDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:scoreDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importIrmFile: Error while creating score directory: %@, %@", error, [error userInfo]);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    
    //  move pdf file to score directory
    NSString *newPdfPath = [scoreDirectoryPath stringByAppendingPathComponent:[pdfFilePath lastPathComponent]];
    [[NSFileManager defaultManager] moveItemAtPath:pdfFilePath toPath:newPdfPath error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importIrmFile: Error while moving pdf file to score directory: %@, %@", error, [error userInfo]);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    
    // set score properties
    newScore.pdfFileName = [pdfFilePath lastPathComponent];
    newScore.name = scoreName;
    newScore.isAnalyzed = [NSNumber numberWithBool:NO];
    
    // remove scoreBlitz file from documents directory
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importIrmFile: Error while deleting scoreBlitz file at importFilePath: %@, %@", error, [error userInfo]);
#endif
    }
    
    // remove temporary files
    [[NSFileManager defaultManager] removeItemAtPath:tempDirectory error:&error];
    
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importIrmFile: Error while deleting tempDirectory: %@, %@", error, [error userInfo]);
#endif
    }
    
    // Finish Succesful Operation
    NSError *contextError;
    if(![self.managedObjectContext save:&contextError]) {
#ifdef DEBUG
        NSLog(@"Error saving context in analyze score: %@", [contextError localizedDescription]);
#endif
    }
    self.managedObjectContext = nil;
    [self finishOperation]; // automatically fires completion block
}

@end
