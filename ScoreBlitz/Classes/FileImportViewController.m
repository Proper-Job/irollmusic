//
//  FileImportViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 23.03.15.
//
//

#import "FileImportViewController.h"
#import "ScoreBlitzAppDelegate.h"
#import "PdfFileImportOperation.h"
#import "IrmFileImportOperation.h"
#import "QueryHelper.h"
#import "SleepManager.h"

#define kFileImportViewControllerSleepIdentifier @"FileImportViewController"

@interface FileImportViewController ()

@end

@implementation FileImportViewController

#pragma mark - Init

- (id)initWithFilePaths:(NSArray*)pdfFilePaths irmFilePaths:(NSArray*)irmFilePaths
{
    if (self = [super init]) {
        self.pdfFilePaths = pdfFilePaths;
        self.irmFilePaths = irmFilePaths;
        
        self.totalOperations = [pdfFilePaths count] + [irmFilePaths count];
        self.finishedOperations = 0;
        self.failedOperations = 0;
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 10;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelImportNotification) name:kCancelScoreImportNotification object:nil];
    }
    return self;
}

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = MyLocalizedString(@"ImportViewControllerFailureMessage", nil);
    self.progressLabel.text = @"0 %";
    
    self.progressView.progressTintColor = [Helpers petrol];
    self.progressView.progress = 0;
    
    [self.cancelButton setTitle:MyLocalizedString(@"buttonCancel", nil) forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [Helpers petrol];
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor];    

    if (([self.pdfFilePaths count] + [self.irmFilePaths count]) > 0) {
        [[SleepManager sharedInstance] addInsomniac:kFileImportViewControllerSleepIdentifier];
    }
    
    for (NSString *pdfFilePath in self.pdfFilePaths) {
        PdfFileImportOperation *pdfFileImportOperation = [[PdfFileImportOperation alloc] initWithFilePath:pdfFilePath];
        [pdfFileImportOperation setCompletionBlockWithSuccess:^(NSString *pdfFilePath) {
            [self importOperationSuccess:pdfFilePath];
        } failure:^(NSString *pdfFilePath) {
            [self importOperationFailure:pdfFilePath];
        }];
        
        [self.operationQueue addOperation:pdfFileImportOperation];
    }
    
    for (NSString *irmFilePath in self.irmFilePaths) {
        IrmFileImportOperation *irmFileImportOperation = [[IrmFileImportOperation alloc] initWithFilePath:irmFilePath];
        [irmFileImportOperation setCompletionBlockWithSuccess:^(NSString *irmFilePath) {
            [self importOperationSuccess:irmFilePath];
        } failure:^(NSString *irmFilePath) {
            [self importOperationFailure:irmFilePath];
        }];
        
        [self.operationQueue addOperation:irmFileImportOperation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interface

- (IBAction)cancelTapped:(id)sender
{
    [self.operationQueue cancelAllOperations];
    [[SleepManager sharedInstance] removeInsomniac:kFileImportViewControllerSleepIdentifier];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneTapped:(id)sender
{
    [[SleepManager sharedInstance] removeInsomniac:kFileImportViewControllerSleepIdentifier];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)importIsFinished
{
    [[SleepManager sharedInstance] removeInsomniac:kFileImportViewControllerSleepIdentifier];
    
    if (self.failedOperations > 0) {
        self.titleLabel.text = MyLocalizedString(@"ImportViewControllerFailureMessage", nil);
    } else {
        self.titleLabel.text = MyLocalizedString(@"ImportViewControllerSuccessMessage", nil);
    }
    [self.cancelButton setTitle:MyLocalizedString(@"buttonDone", nil) forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Import Operation CallBacks

- (void)importOperationFailure:(NSString*)filePatch
{
    self.finishedOperations++;
    self.failedOperations++;
    
    CGFloat fullProgress = 1.0 / (float)self.totalOperations * (float)self.finishedOperations;
    int intProgress = (int)roundf(fullProgress * 100);
    self.progressLabel.text = [NSString stringWithFormat:@"%d %%", intProgress];
    [self.progressView setProgress:fullProgress animated:YES];

    if (self.finishedOperations == self.totalOperations) {
        [self importIsFinished];
    }
}

- (void)importOperationSuccess:(NSString*)filePatch
{
    self.finishedOperations++;

    CGFloat fullProgress = 1.0 / (float)self.totalOperations * (float)self.finishedOperations;
    int intProgress = (int)roundf(fullProgress * 100);
    self.progressLabel.text = [NSString stringWithFormat:@"%d %%", intProgress];
    [self.progressView setProgress:fullProgress animated:YES];
    
    if (self.finishedOperations == self.totalOperations) {
        [self importIsFinished];
    }
}

#pragma mark - Import Status

+ (NSArray*)pdfFilePaths
{
    NSError *error = nil;
    NSMutableArray *pdfFilesToTest = [NSMutableArray array];
    NSMutableArray *validPdfFiles = [NSMutableArray array];
    NSString *documentsDirectoryPath = [[UIAppDelegate applicationDocumentsDirectory] path];
    
    NSArray *documentsDirectoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
    
    if ([documentsDirectoryContent count] > 0) {
        NSIndexSet *indexSetOfPdfFiles = [documentsDirectoryContent indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString *pathExtension = [(NSString *)obj pathExtension];
            return [kPdfFileExtensions containsObject:pathExtension];
        }];
        
        for (NSString *relativePath in [documentsDirectoryContent objectsAtIndexes:indexSetOfPdfFiles]) {
            [pdfFilesToTest addObject:[documentsDirectoryPath stringByAppendingPathComponent:relativePath]];
        }
    }
    
    if ([pdfFilesToTest count] > 0) {
        NSIndexSet *indexSetOfValidPdfFiles = [pdfFilesToTest indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [Helpers verifyPdfFile:(NSString *)obj];
        }];
        
        [validPdfFiles addObjectsFromArray:[pdfFilesToTest objectsAtIndexes:indexSetOfValidPdfFiles]];
    }
    
    return validPdfFiles;
}

+ (NSArray*)irmFilePaths
{
    NSError *error = nil;
    NSMutableArray *irmFiles = [NSMutableArray array];
    NSString *documentsDirectoryPath = [[UIAppDelegate applicationDocumentsDirectory] path];
    
    NSArray *documentsDirectoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
    
    if ([documentsDirectoryContent count] > 0) {
        NSIndexSet *indexSetOfIrmFiles = [documentsDirectoryContent indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString *pathExtension = [(NSString *)obj pathExtension];
            return [kIrmFileExtensions containsObject:pathExtension];
        }];
        
        for (NSString *relativePath in [documentsDirectoryContent objectsAtIndexes:indexSetOfIrmFiles]) {
            [irmFiles addObject:[documentsDirectoryPath stringByAppendingPathComponent:relativePath]];
        }
    }
    
    return irmFiles;
}

+ (BOOL)filesInDocumentsDirectory
{
    NSInteger numberOfFilesPaths = [[FileImportViewController pdfFilePaths] count] + [[FileImportViewController irmFilePaths] count];
    
    if (numberOfFilesPaths > 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Notifications

- (void)cancelImportNotification
{
    [self cancelTapped:nil];
}

@end
