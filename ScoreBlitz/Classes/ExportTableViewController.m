//
//  ExportTableViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import "ExportTableViewController.h"
#import "ExportTableViewCell.h"
#import "ExportButtonTableViewCell.h"
#import "ExportSectionItem.h"
#import "ExportItem.h"
#import "Score.h"
#import "ScorePrintPageRenderer.h"
#import "TrackingManager.h"
#import "ScoreManager.h"
#import "APCheckedLabel.h"
#import "PdfFileExportOperation.h"
#import "IrmFileExportOperation.h"
#import "ScoreDetailTableViewController.h"

@interface ExportTableViewController ()

@end

@implementation ExportTableViewController

- (id)initWithScore:(Score*)score
{
    self = [super initWithNibName:@"ExportTableViewController" bundle:nil];
    if (self) {
        self.score = score;
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = MyLocalizedString(@"exportOptionsTitle", nil);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ExportTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExportTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ExportButtonTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExportButtonTableViewCell"];
    
    NSMutableArray *newSections = [NSMutableArray array];
    
    if ([MFMailComposeViewController canSendMail]) {
        NSMutableArray *emailExportItems = [NSMutableArray array];
        
        ExportItem *annotationsItem = [[ExportItem alloc] init];
        annotationsItem.title = MyLocalizedString(@"exportDialogPdfAnnotationsSelector", nil);
        annotationsItem.boolValue = YES;
        annotationsItem.exportTableViewCellStyle = ExportTableViewCellStyleRegular;
        annotationsItem.exportActionType = ExportActionTypeFileAnnotationsChecked;
        [emailExportItems addObject:annotationsItem];
        
        ExportItem *pdfButtonItem = [[ExportItem alloc] init];
        pdfButtonItem.title = MyLocalizedString(@"exportDialogPdfFileButton", nil);
        pdfButtonItem.exportTableViewCellStyle = ExportTableViewCellStyleButton;
        pdfButtonItem.exportActionType = ExportActionTypePdfFile;
        [emailExportItems addObject:pdfButtonItem];
        
        ExportItem *irmButtonItem = [[ExportItem alloc] init];
        irmButtonItem.title = MyLocalizedString(@"exportDialogProprietaryFileButton", nil);
        irmButtonItem.exportTableViewCellStyle = ExportTableViewCellStyleButton;
        irmButtonItem.exportActionType = ExportActionTypeIrmFile;
        [emailExportItems addObject:irmButtonItem];
        
        ExportSectionItem *emailExportSectionItem = [[ExportSectionItem alloc] init];
        emailExportSectionItem.title = MyLocalizedString(@"fileExportTitle", nil);
        emailExportSectionItem.rows = emailExportItems;
        [newSections addObject:emailExportSectionItem];
        
        self.sections = newSections;
    }
    
    if ([UIPrintInteractionController isPrintingAvailable]) {
        NSMutableArray *printExportItems = [NSMutableArray array];
        
        ExportItem *annotationsItem = [[ExportItem alloc] init];
        annotationsItem.title = MyLocalizedString(@"printDialogAnnotationsSelector", nil);
        annotationsItem.boolValue = NO;
        annotationsItem.exportTableViewCellStyle = ExportTableViewCellStyleRegular;
        annotationsItem.exportActionType = ExportActionTypePrintAnnotationsChecked;
        [printExportItems addObject:annotationsItem];
        
        ExportItem *printModeItem = [[ExportItem alloc] init];
        printModeItem.title = MyLocalizedString(@"printDialogPrintModeSelector", nil);
        printModeItem.boolValue = NO;
        printModeItem.exportTableViewCellStyle = ExportTableViewCellStyleRegular;
        printModeItem.exportActionType = ExportActionTypePrintModeChecked;
        [printExportItems addObject:printModeItem];
        
        ExportItem *printButtonItem = [[ExportItem alloc] init];
        printButtonItem.title = MyLocalizedString(@"printDialogPrintButton", nil);
        printButtonItem.exportTableViewCellStyle = ExportTableViewCellStyleButton;
        printButtonItem.exportActionType = ExportActionTypePrint;
        [printExportItems addObject:printButtonItem];
        
        ExportSectionItem *printExportSectionItem = [[ExportSectionItem alloc] init];
        printExportSectionItem.title = MyLocalizedString(@"printerOptionsTitle", nil);
        printExportSectionItem.rows = printExportItems;
        [newSections addObject:printExportSectionItem];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (void)buttonTapped:(UIButton*)sender
{
    switch (sender.tag) {
        case ExportActionTypePdfFile: {
            [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:kExportDialogViewController actionString:kTrackingEventButton labelString:kExportPdf valueNumber:[NSNumber numberWithInt:0]];
            [self exportPdfWithAnnotations:self.fileAnnotationsChecked.isChecked];
            break;
        }

        case ExportActionTypeIrmFile: {
            [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:kExportDialogViewController actionString:kTrackingEventButton labelString:kExportIrm valueNumber:[NSNumber numberWithInt:0]];
            [self exportIrmWithAnnoations:self.fileAnnotationsChecked.isChecked];
            break;
        }
            
        default: { //ExportActionTypePrint
            [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:kExportDialogViewController actionString:kTrackingEventButton labelString:kPrintScore valueNumber:[NSNumber numberWithInt:0]];            
            [self printScoreWithAnnotations:self.printAnnotationsChecked.isChecked inLandscapeMode:self.printModeChecked.isChecked];
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.sections objectAtIndex:section] rows] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExportItem *exportItem = [[[self.sections objectAtIndex:indexPath.section] rows] objectAtIndex:indexPath.row];
    
    if (exportItem.exportTableViewCellStyle == ExportTableViewCellStyleRegular) {
        ExportTableViewCell *cell = (ExportTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ExportTableViewCell" forIndexPath:indexPath];
        [cell setupWithExportItem:exportItem];
        
        switch (exportItem.exportActionType) {
            case ExportActionTypeFileAnnotationsChecked: {
                self.fileAnnotationsChecked = cell.checkedLabel;
                break;
            }
                
            case ExportActionTypePrintAnnotationsChecked: {
                self.printAnnotationsChecked = cell.checkedLabel;
                break;
            }
                
                
            default: { // ExportActionTypePrintModeChecked
                self.printModeChecked = cell.checkedLabel;
                break;
            }
        }
        
        return cell;
    } else {
        ExportButtonTableViewCell *cell = (ExportButtonTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ExportButtonTableViewCell" forIndexPath:indexPath];
        [cell setupWithExportItem:exportItem];
        cell.button.tag = exportItem.exportActionType;
        [cell.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExportItem *exportItem = [[[self.sections objectAtIndex:indexPath.section] rows] objectAtIndex:indexPath.row];
    if (exportItem.exportTableViewCellStyle == ExportTableViewCellStyleRegular) {
        return 44.0;
    } else {
        return 65.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ExportSectionItem *exportSectionItem = [self.sections objectAtIndex:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0, self.view.bounds.size.width - 40.0, 44.0)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.font = [Helpers avenirNextMediumFontWithSize:18.0];
    titleLabel.text = exportSectionItem.title;
    [headerView addSubview:titleLabel];
    
    return headerView;
}


#pragma mark - Data Operations

- (void)printScoreWithAnnotations:(BOOL)annotations inLandscapeMode:(BOOL)landscapeMode
{
    self.printInteractionController = [UIPrintInteractionController sharedPrintController];
    
    if  (self.printInteractionController && [UIPrintInteractionController canPrintURL:[self.score scoreUrl]]) {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = self.score.name;
        printInfo.duplex = UIPrintInfoDuplexNone;
        if (landscapeMode) {
            printInfo.orientation = UIPrintInfoOrientationLandscape;
        } else {
            printInfo.orientation = UIPrintInfoOrientationPortrait;
        }
        
        self.printInteractionController.printInfo = printInfo;
        self.printInteractionController.showsPageRange = YES;
        self.printInteractionController.delegate = self;
        
        ScorePrintPageRenderer *scorePrintPageRenderer = [[ScorePrintPageRenderer alloc] initWithScore:self.score];
        scorePrintPageRenderer.printAnnotations = annotations;
        self.printInteractionController.printPageRenderer = scorePrintPageRenderer;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            //self.content = nil;
            if (!completed && error) {
                if (APP_DEBUG) {
                    NSLog(@"FAILED! due to error in domain %@ with error code %u",
                          error.domain, error.code);
                }
            }
        };

        [self.printInteractionController presentFromRect:self.view.frame inView:self.view animated:YES completionHandler:completionHandler];
    }
}



- (void)sendEmailWithAttachment:(NSString*)filePath mimeType:(NSString*)mimeType
{
    MFMailComposeViewController *mailComposerController = [[MFMailComposeViewController alloc] init];
    mailComposerController.mailComposeDelegate = self;
    [mailComposerController setSubject:self.score.name];
    if ([mimeType isEqualToString:kScoreBlitzMimeType]) {
        [mailComposerController addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:filePath] mimeType:kScoreBlitzMimeType fileName:[filePath lastPathComponent]];
    } else {
        [mailComposerController addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:filePath] mimeType:kPdfMimeType fileName:[self.score.name stringByAppendingString:@".pdf"]];
    }
    
    [self presentViewController:mailComposerController animated:YES completion:nil];
}

- (void)exportPdfWithAnnotations:(BOOL)withAnnotations
{
    PdfFileExportOperation *pdfFileExportOperation = [[PdfFileExportOperation alloc] initWithScore:self.score];
    pdfFileExportOperation.withAnnotations = withAnnotations;
    [pdfFileExportOperation setCompletionBlockWithSuccess:^(NSString *exportFilePath) {
        self.exportFilePath = exportFilePath;
        [self sendEmailWithAttachment:exportFilePath mimeType:kPdfMimeType];
    } failure:^(NSString *errorMessage) {
        if (errorMessage != nil) {
            [self presentViewController:[Helpers alertControllerWithTitle:nil message:errorMessage] animated:YES completion:nil];
        }
    }];
    [self.operationQueue addOperation:pdfFileExportOperation];
}

- (void)exportIrmWithAnnoations:(BOOL)withAnnotations
{
    IrmFileExportOperation *irmFileExportOperation = [[IrmFileExportOperation alloc] initWithScore:self.score];
    irmFileExportOperation.withAnnotations = withAnnotations;
    [irmFileExportOperation setCompletionBlockWithSuccess:^(NSString *exportFilePath) {
        self.exportFilePath = exportFilePath;
        [self sendEmailWithAttachment:exportFilePath mimeType:kScoreBlitzMimeType];
    } failure:^(NSString *errorMessage) {
        if (errorMessage != nil) {
            [self presentViewController:[Helpers alertControllerWithTitle:nil message:errorMessage] animated:YES completion:nil];
        }
    }];
    [self.operationQueue addOperation:irmFileExportOperation];
}

#pragma mark -
#pragma mark MFMailComposer delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [Helpers removeFileAtPath:self.exportFilePath];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (error == nil) {
            // Notifies users about errors associated with the interface
            switch (result)
            {
                case MFMailComposeResultCancelled: {
                    if (APP_DEBUG) {
                        NSLog(@"%s: Result: canceled", __func__);
                    }
                    
                    break;
                }
                    
                case MFMailComposeResultSaved: {
                    if (APP_DEBUG) {
                        NSLog(@"%s: Result: saved", __func__);
                    }
                    break;
                }
                    
                case MFMailComposeResultSent: {
                    if (APP_DEBUG) {
                        NSLog(@"%s: Result: sent", __func__);
                    }
                    break;
                }
                    
                case MFMailComposeResultFailed: {
                    if (APP_DEBUG) {
                        NSLog(@"%s: Result: failed", __func__);
                    }
                    
                    UIAlertController *alertController = [Helpers alertControllerWithTitle:MyLocalizedString(@"SendMailFailedAlertViewTitle", nil) message:MyLocalizedString(@"SendMailFailedAlertViewMessage", nil)];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                    break;
                }
                    
                default: {
                    if (APP_DEBUG) {
                        NSLog(@"%s: Result: not sent", __func__);
                    }
                    break;
                }
            }
        } else {
            UIAlertController *alertController = [Helpers alertControllerWithTitle:nil message:[error localizedDescription]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

#pragma mark -
#pragma mark UIPrintInteractionControllerDelegate

- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    self.printInteractionController = nil;
    //[self.delegate dissmissExportDialogViewController];
}


@end
