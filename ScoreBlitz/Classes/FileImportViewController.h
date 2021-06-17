//
//  FileImportViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 23.03.15.
//
//

#import <UIKit/UIKit.h>

@interface FileImportViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *titleLabel, *progressLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) NSArray *pdfFilePaths, *irmFilePaths;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, assign) NSInteger totalOperations, finishedOperations, failedOperations;

- (id)initWithFilePaths:(NSArray*)pdfFilePaths irmFilePaths:(NSArray*)irmFilePaths;

+ (NSArray*)pdfFilePaths;
+ (NSArray*)irmFilePaths;
+ (BOOL)filesInDocumentsDirectory;

@end
