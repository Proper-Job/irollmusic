//
//  DropboxTransferListViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import "DropboxTransferListViewController.h"
#import "DropboxTransferManager.h"
#import "DropboxFileTransferListInboundCell.h"
#import "DropboxFileTransferListOutboundCell.h"
#import "PureLayout.h"
#import "QueryHelper.h"
#import "MZFormSheetPresentationController.h"

@interface DropboxTransferListViewController ()

@end

@implementation DropboxTransferListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add file notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFileToTransferListNotification:) name:kLibraryDropboxAddFileToTransferListNotification object:nil];

    // Cells
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSelectorInOutboundCellToggled:) name:kFileSelectorInOutBoundCellToggled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationsSelectorInOutboundCellToggled:) name:kAnnotationsSelectorInOutBoundCellToggled object:nil];
    
    // TranferFile
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferDidFail:) name:kTransferDidFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelTransfer:) name:kDidCancelTransfer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferSuccess:) name:kTransferSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferFileProgressDidChange:) name:kTransferFileProgressDidChange object:nil];
    
    // DropboxTransferManager
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxTransferManagerDidStartFileTransfer) name:kDropboxTransferManagerDidStartFileTransfer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxTransferManagerDidEndFileTransfer) name:kDropboxTransferManagerDidEndFileTransfer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivityIndicatorForTransferManager) name:kShowActivityIndicatorInDropboxViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideActivityIndicatorForTransferManager) name:kHideActivityIndicatorInDropboxViewController object:nil];
    
    self.titleLabel.text = MyLocalizedString(@"transferListLabelText", nil);
    [self updateTransferVolumeLabel];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DropboxFileTransferListOutboundCell" bundle:nil] forCellReuseIdentifier:@"DropboxFileTransferListOutboundCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DropboxFileTransferListInboundCell" bundle:nil] forCellReuseIdentifier:@"DropboxFileTransferListInboundCell"];    
    self.automaticallyAdjustsScrollViewInsets = NO;

    DropboxTransferManager *dropboxTransferManager = [DropboxTransferManager sharedInstance];
    self.transferToDropboxFiles = [NSMutableArray array];
    self.transferToIrollMusicFiles = [NSMutableArray array];
    
    if ([dropboxTransferManager isTransfering]) {
        //[self.transferToIrollMusicFiles addObjectsFromArray:dropboxTransferManager.inboxFiles];
        //[self.transferToDropboxFiles addObjectsFromArray:dropboxTransferManager.outboxFiles];
        
        self.startTransferButton.title = MyLocalizedString(@"transferButtonCancelTitle", nil);
        self.startTransferButton.action = @selector(startTransfer);
    } else {
        self.startTransferButton.title = MyLocalizedString(@"transferButtonStartTitle", nil);
        self.startTransferButton.action = @selector(startTransfer);
    }
    self.startTransferButton.target = self;
    
    self.clearTransferListButton.title = MyLocalizedString(@"clearTransferListButtonTitle", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDeleteButtonStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateDeleteButtonStatus
{
    if ([self.tableView indexPathForSelectedRow]) {
        self.deleteButton.enabled = YES;
    } else {
        self.deleteButton.enabled = NO;
    }
}

#pragma mark - Button actions

- (IBAction)startTransfer
{
    self.deleteButton.enabled = NO;
    self.clearTransferListButton.enabled = NO;

    self.startTransferButton.enabled = NO;
    [[DropboxTransferManager sharedInstance] startTransferwithInboxFiles:self.transferToIrollMusicFiles andOutboxFiles:self.transferToDropboxFiles];
}

- (IBAction)cancelTransfer
{
    self.startTransferButton.enabled = NO;
    [[DropboxTransferManager sharedInstance] cancelTransfer];
}

- (IBAction)deleteFileFromTransferListTapped
{
    if ([[DropboxTransferManager sharedInstance] isTransfering]) {
        // show alert?
    } else {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        if (nil != indexPath) {
            TransferFile *transferFile;
            
            if (indexPath.section == 0) {
                transferFile = [self.transferToIrollMusicFiles objectAtIndex:indexPath.row];
            } else {
                transferFile = [self.transferToDropboxFiles objectAtIndex:indexPath.row];
            }
            
            [self removeFileFromTransferList:transferFile];
        }
    }
}

- (IBAction)clearTransferListTapped
{
    if ([[DropboxTransferManager sharedInstance] isTransfering]) {
        // show alert?
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"clearTranferListAlertViewTitle", nil)
                                                                       message:MyLocalizedString(@"clearTranferListAlertViewMessage", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
                                                             [self clearTransferList];
                                                         }];
        [alert addAction:okAction];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {}];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.transferToIrollMusicFiles count];
    } else {
        return [self.transferToDropboxFiles count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DropboxFileTransferListInboundCell *cell = (DropboxFileTransferListInboundCell*)[self.tableView dequeueReusableCellWithIdentifier:@"DropboxFileTransferListInboundCell" forIndexPath:indexPath];
        
        
        TransferFile *transferFile = [self.transferToIrollMusicFiles objectAtIndex:indexPath.row];
        cell.label.text = transferFile.fileName;

        if (transferFile.transferCompleted || transferFile.transferFailed || transferFile.transferCanceled) {
            cell.progressView.hidden = YES;
            cell.doneLabel.text = [transferFile doneString];
            cell.doneLabel.hidden = NO;
        } else {
            cell.progressView.hidden = YES;
            cell.doneLabel.hidden = YES;
        }
        return cell;
        
    } else {
        DropboxFileTransferListOutboundCell *cell = (DropboxFileTransferListOutboundCell*)[self.tableView dequeueReusableCellWithIdentifier:@"DropboxFileTransferListOutboundCell" forIndexPath:indexPath];
        
        
        TransferFile *transferFile = [self.transferToDropboxFiles objectAtIndex:indexPath.row];
        cell.label.text = transferFile.fileName;
        
        [cell.fileSelector setTitle:MyLocalizedString(@"transferListOutboundCellPdfText", nil) forSegmentAtIndex:0];
        [cell.fileSelector setTitle:MyLocalizedString(@"transferListOutboundCellIrmText", nil) forSegmentAtIndex:1];
        cell.fileSelector.selectedSegmentIndex = transferFile.iRollMusicFile;
        
        if (transferFile.transferCompleted || transferFile.transferFailed || transferFile.transferCanceled) {
            cell.progressView.hidden = YES;
            cell.doneLabel.text = [transferFile doneString];
            cell.doneLabel.hidden = NO;
        } else {
            cell.progressView.hidden = YES;
            cell.doneLabel.hidden = YES;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TransferFile *transferFile;

    if (indexPath.section == 0) {
        transferFile = [self.transferToIrollMusicFiles objectAtIndex:indexPath.row];
    } else {
        transferFile = [self.transferToDropboxFiles objectAtIndex:indexPath.row];
    }
    
    [self removeFileFromTransferList:transferFile];
}


#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 88.0;
    } else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDeleteButtonStatus];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (section == 0) {
        if ([self.transferToIrollMusicFiles count] > 0) {
            title = MyLocalizedString(@"transferToIrollMusicHeader", nil);
        } else {
            return nil;
        }
    } else {
        if ([self.transferToDropboxFiles count] > 0) {
            title = MyLocalizedString(@"transferToDropboxHeader", nil);
        } else {
            return nil;
        }
    }
    
    UIView *hostingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44.0)];
    hostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0, self.tableView.bounds.size.width - 40.0, 44.0)];
    sectionTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sectionTitleLabel.textColor = [UIColor blackColor];
    sectionTitleLabel.font = [Helpers avenirNextMediumFontWithSize:18.0];
    sectionTitleLabel.text = title;
    
    [hostingView addSubview:sectionTitleLabel];
    return hostingView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

#pragma mark - TransferFile Handling

- (void)addFileToTransferList:(TransferFile*)fileToAdd
{
    NSUInteger newTransferFileIndex;
    NSInteger section;
    BOOL fileAdded = NO;
    
    if (nil == fileToAdd.score) {
        [self.transferToIrollMusicFiles addObject:fileToAdd];
        newTransferFileIndex = [self.transferToIrollMusicFiles indexOfObject:fileToAdd];
        section = 0;
        fileAdded = YES;
    } else {
        [self.transferToDropboxFiles addObject:fileToAdd];
        newTransferFileIndex = [self.transferToDropboxFiles indexOfObject:fileToAdd];
        section = 1;
        fileAdded = YES;
    }
    
    if (fileAdded) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newTransferFileIndex inSection:section];
        NSArray *arrayOfIndexPaths = [NSArray arrayWithObjects:newIndexPath, nil];
        
        // animation for regular tableView
        [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        
        [self updateTransferVolumeLabel];
    }
}

- (void)removeFileFromTransferList:(TransferFile*)fileToRemove
{
    NSInteger section;
    NSInteger row;
    NSInteger numberOfRowsAfterDelete;
    BOOL deleteFromTableView = NO;
    
    if ([self.transferToIrollMusicFiles containsObject:fileToRemove]) {
        section = 0;
        row = [self.transferToIrollMusicFiles indexOfObject:fileToRemove];
        [self.transferToIrollMusicFiles removeObject:fileToRemove];
        numberOfRowsAfterDelete = [self.transferToIrollMusicFiles count];
        deleteFromTableView = YES;
    } else if ([self.transferToDropboxFiles containsObject:fileToRemove]) {
        section = 1;
        row = [self.transferToDropboxFiles indexOfObject:fileToRemove];
        [self.transferToDropboxFiles removeObject:fileToRemove];
        numberOfRowsAfterDelete = [self.transferToDropboxFiles count];
        deleteFromTableView = YES;
    }
    
    if (deleteFromTableView) {
        NSIndexPath *indexPathDelete = [NSIndexPath indexPathForRow:row inSection:section];
        NSArray *indexPathsDelete = [NSArray arrayWithObject:indexPathDelete];
        
        [self.tableView deleteRowsAtIndexPaths:indexPathsDelete withRowAnimation:UITableViewRowAnimationBottom];
        
        if (numberOfRowsAfterDelete > 0) {
            NSInteger rowToSelect;
            if ((row -1) >= 0) {
                rowToSelect = row -1;
            } else {
                rowToSelect = row;
            }
            
            NSIndexPath *indexPathSelect = [NSIndexPath indexPathForRow:rowToSelect inSection:section];
            
            [self.tableView selectRowAtIndexPath:indexPathSelect animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPathSelect];
        } else {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [self updateTransferVolumeLabel];
}

- (void)clearTransferList
{
    [self.transferToIrollMusicFiles removeAllObjects];
    [self.transferToDropboxFiles removeAllObjects];
    [self.tableView reloadData];
    
    [self updateDeleteButtonStatus];
    [self updateTransferVolumeLabel];    
}

- (void)updateTransferVolumeLabel
{
    double transferVolume = 0; // in kb
    
    for (TransferFile *transferFile in self.transferToIrollMusicFiles) {
        transferVolume = transferVolume + transferFile.fileSize;
    }
    
    for (TransferFile *transferFile in self.transferToDropboxFiles) {
        transferVolume = transferVolume + transferFile.fileSize;
    }
    
    NSString *transferVolumeString = [NSString stringWithFormat:@"%.02f MB", transferVolume/1024];
    
    self.transferVolumeLabel.text = transferVolumeString;
}

#pragma amrk - Cell Notifications

- (void)fileSelectorInOutboundCellToggled:(NSNotification*)notification
{
    DropboxFileTransferListOutboundCell *outboundCell = (DropboxFileTransferListOutboundCell*)[notification object];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:outboundCell];
    
    if (indexPath.section == 1) {
        TransferFile *transferFile = [self.transferToDropboxFiles objectAtIndex:indexPath.row];
        transferFile.iRollMusicFile = outboundCell.fileSelector.selectedSegmentIndex;
    }
}

- (void)annotationsSelectorInOutboundCellToggled:(NSNotification*)notification
{
    DropboxFileTransferListOutboundCell *outboundCell = (DropboxFileTransferListOutboundCell*)[notification object];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:outboundCell];
    
    if (indexPath.section == 1) {
        TransferFile *transferFile = [self.transferToDropboxFiles objectAtIndex:indexPath.row];
        transferFile.annotations = outboundCell.annotationsSelector.selectedSegmentIndex;
    }
}

#pragma mark - TranferFile Notifications

- (void)addFileToTransferListNotification:(NSNotification*)notification
{
    TransferFile *transferFile = [[notification userInfo] objectForKey:kLibraryDropboxAddFileToTransferListNotificationObject];
    
    if (transferFile.score != nil) {
        NSArray *result = [self.transferToDropboxFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"score == %@", transferFile.score]];
        if ([result count] == 0) {
            [self addFileToTransferList:transferFile];
        }
    } else if (transferFile.dropboxFile != nil) {
        NSArray *result = [self.transferToIrollMusicFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"dropboxFile == %@", transferFile.dropboxFile]];
        if ([result count] == 0) {
            [self addFileToTransferList:transferFile];
        }
    }
}

- (void)transferFileProgressDidChange:(NSNotification*)notification
{
    TransferFile *transferFile = (TransferFile*)[notification object];
    NSNumber *progressNumber = [[notification userInfo] objectForKey:kTransferFileProgressDidChangeValue];
    CGFloat progress = [progressNumber floatValue];
    
    NSInteger section;
    NSInteger row;
    if ([self.transferToIrollMusicFiles containsObject:transferFile]) {
        section = 0;
        row = [self.transferToIrollMusicFiles indexOfObject:transferFile];
    } else if ([self.transferToDropboxFiles containsObject:transferFile]) {
        section = 1;
        row = [self.transferToDropboxFiles indexOfObject:transferFile];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DropboxFileTransferListInboundCell class]]) {
        DropboxFileTransferListInboundCell *inboundCell = (DropboxFileTransferListInboundCell*)cell;
        if (progress == 0) {
            inboundCell.progressView.hidden = YES;
            inboundCell.doneLabel.hidden = YES;
        } else {
            inboundCell.progressView.hidden = NO;
            inboundCell.doneLabel.hidden = YES;
        }
        inboundCell.progressView.progress = progress;
    } else if ([cell isKindOfClass:[DropboxFileTransferListOutboundCell class]]) {
        DropboxFileTransferListOutboundCell *outboundCell = (DropboxFileTransferListOutboundCell*)cell;
        if (progress == 0) {
            outboundCell.progressView.hidden = YES;
            outboundCell.doneLabel.hidden = YES;
        } else {
            outboundCell.progressView.hidden = NO;
            outboundCell.doneLabel.hidden = YES;
        }
        outboundCell.progressView.progress = progress;
    }
}


- (void)didCancelTransfer:(NSNotification*)notification
{
    TransferFile *transferFile = (TransferFile*)[notification object];
    NSInteger section;
    NSInteger row;
    if ([self.transferToIrollMusicFiles containsObject:transferFile]) {
        section = 0;
        row = [self.transferToIrollMusicFiles indexOfObject:transferFile];
    } else if ([self.transferToDropboxFiles containsObject:transferFile]) {
        section = 1;
        row = [self.transferToDropboxFiles indexOfObject:transferFile];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DropboxFileTransferListInboundCell class]]) {
        DropboxFileTransferListInboundCell *inboundCell = (DropboxFileTransferListInboundCell*)cell;
        inboundCell.progressView.hidden = YES;
        inboundCell.doneLabel.text = [transferFile canceledString];
        inboundCell.doneLabel.hidden = NO;
    } else if ([cell isKindOfClass:[DropboxFileTransferListOutboundCell class]]) {
        DropboxFileTransferListOutboundCell *outboundCell = (DropboxFileTransferListOutboundCell*)cell;
        outboundCell.progressView.hidden = YES;
        outboundCell.doneLabel.text = [transferFile canceledString];
        outboundCell.doneLabel.hidden = NO;
    }
}

- (void)transferSuccess:(NSNotification*)notification
{
    TransferFile *transferFile = (TransferFile*)[notification object];
    
    NSInteger section;
    NSInteger row;
    if ([self.transferToIrollMusicFiles containsObject:transferFile]) {
        section = 0;
        row = [self.transferToIrollMusicFiles indexOfObject:transferFile];
    } else if ([self.transferToDropboxFiles containsObject:transferFile]) {
        section = 1;
        row = [self.transferToDropboxFiles indexOfObject:transferFile];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DropboxFileTransferListInboundCell class]]) {
        DropboxFileTransferListInboundCell *inboundCell = (DropboxFileTransferListInboundCell*)cell;
        inboundCell.progressView.hidden = YES;
        inboundCell.doneLabel.text = [transferFile doneString];
        inboundCell.doneLabel.hidden = NO;
    } else if ([cell isKindOfClass:[DropboxFileTransferListOutboundCell class]]) {
        DropboxFileTransferListOutboundCell *outboundCell = (DropboxFileTransferListOutboundCell*)cell;
        outboundCell.progressView.hidden = YES;
        outboundCell.doneLabel.text = [transferFile doneString];
        outboundCell.doneLabel.hidden = NO;
    }
}

- (void)transferDidFail:(NSNotification*)notification
{
    TransferFile *transferFile = (TransferFile*)[notification object];
    NSString *errorMessage = [[notification userInfo] objectForKey:kTransferDidFailMessage];
    
    NSInteger section;
    NSInteger row;
    if ([self.transferToIrollMusicFiles containsObject:transferFile]) {
        section = 0;
        row = [self.transferToIrollMusicFiles indexOfObject:transferFile];
    } else if ([self.transferToDropboxFiles containsObject:transferFile]) {
        section = 1;
        row = [self.transferToDropboxFiles indexOfObject:transferFile];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DropboxFileTransferListInboundCell class]]) {
        DropboxFileTransferListInboundCell *inboundCell = (DropboxFileTransferListInboundCell*)cell;
        inboundCell.progressView.hidden = YES;
        if (errorMessage == nil) {
            inboundCell.doneLabel.text = [transferFile failedString];
        } else {
            inboundCell.doneLabel.text = errorMessage;
        }
        inboundCell.doneLabel.hidden = NO;
    } else if ([cell isKindOfClass:[DropboxFileTransferListOutboundCell class]]) {
        DropboxFileTransferListOutboundCell *outboundCell = (DropboxFileTransferListOutboundCell*)cell;
        outboundCell.progressView.hidden = YES;
        if (errorMessage == nil) {
            outboundCell.doneLabel.text = [transferFile failedString];
        } else {
            outboundCell.doneLabel.text = errorMessage;
        }
        outboundCell.doneLabel.hidden = NO;
    }
}

#pragma mark - DropboxTransferManager Notifications

- (void)dropboxTransferManagerDidStartFileTransfer
{
    self.startTransferButton.title = MyLocalizedString(@"transferButtonCancelTitle", nil);
    self.startTransferButton.action = @selector(cancelTransfer);
    self.startTransferButton.enabled = YES;
}

- (void)dropboxTransferManagerDidEndFileTransfer
{
    self.deleteButton.enabled = YES;
    self.clearTransferListButton.enabled = YES;
    
    self.startTransferButton.title = MyLocalizedString(@"transferButtonStartTitle", nil);
    self.startTransferButton.action = @selector(startTransfer);
    self.startTransferButton.enabled = YES;
}

- (void)showActivityIndicatorForTransferManager
{
    //[self performSelectorInBackground:@selector(showActivityIndicator) withObject:nil];
}

- (void)hideActivityIndicatorForTransferManager
{
    /*
    [self._activityIndicatorCondition lock];
    while (!self._activityIndicatorIsRunning) {
        [self._activityIndicatorCondition wait];
    }
    
    [self hideActivityIndicator];
    
    [self._activityIndicatorCondition unlock];*/
}


@end
