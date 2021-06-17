//
//  ScoreImportOperation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 23.03.15.
//
//

#import "PdfFileImportOperation.h"
#import "ScoreBlitzAppDelegate.h"
#import "Score.h"
#import "NSString+Digest.h"

@implementation PdfFileImportOperation

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
    
    [self importPdfFile];
}


#pragma mark - Import

- (void)importPdfFile
{
    // variables
    NSError *error = nil;
    NSString *pdfTitle = nil;
    
    // create pdf document
    NSURL *pdfUrl = [NSURL fileURLWithPath:self.filePath];
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL ((__bridge CFURLRef) pdfUrl);
        
    // get the info dictionary from pdf file
    CGPDFDictionaryRef dictionary = CGPDFDocumentGetInfo (pdfDocument);
        
    // get pdf title from dictionary
    const char *key = "Title";
    CGPDFStringRef retVal;
    
    if (CGPDFDictionaryGetString(dictionary, key, &retVal)) {  // if title present use that title
        // get pdf title and prepare paths
        pdfTitle = (NSString *) CFBridgingRelease(CGPDFStringCopyTextString(retVal));
    }    
    CGPDFDocumentRelease(pdfDocument);
    
    // generate hash with filename and modification date
    NSString *fileName = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
    NSDate *now = [NSDate date];
    NSString *hashForFile = [[fileName stringByAppendingFormat:@"%ld", (long)[now timeIntervalSince1970]]  SHA1];
    
    Score *newScore = (Score *) [[NSManagedObject alloc] initWithEntity:[Score entityDescription]
                                         insertIntoManagedObjectContext:self.managedObjectContext];
    newScore.pdfFileName = [self.filePath lastPathComponent];
    if (nil == pdfTitle) {
        newScore.name = fileName;
    }else {
        newScore.name = pdfTitle;
    }
    newScore.sha1Hash = hashForFile;
    
#ifdef DEBUG
    NSLog(@"importPdfFile: new score: %@", newScore);
#endif
    
    // generate name for scoreDirectory and create directory
    [[NSFileManager defaultManager] createDirectoryAtPath:[newScore scoreDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importPdfFile: Error while creating score directory: %@, %@", error, [error userInfo]);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
    }
    
    NSString *newPdfPath = [[newScore scoreDirectory] stringByAppendingPathComponent:newScore.pdfFileName];
    
    [[NSFileManager defaultManager] moveItemAtPath:self.filePath toPath:newPdfPath error:&error];
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"importPdfFile: Error while moving pdf file to score directory: %@, %@", error, [error userInfo]);
#endif
        self.errorMessage = [error localizedDescription];
        self.failure = YES;
        [self finishOperation];
        return;
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
