//
//  DropboxRemoteFilesViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import "DropboxRemoteFilesViewController.h"
#import "TransferFile.h"
#import "DropboxFileListTableViewCell.h"
#import "DropboxFileDeleteOperation.h"

@interface DropboxRemoteFilesViewController ()

@end

@implementation DropboxRemoteFilesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.files = [NSArray array];
        self.filteredFiles = [NSArray array];
        self.searchPredicate = nil;
        
        self.dbUserClient = [DBClientsManager authorizedClient];
        
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *dropboxPath = MyLocalizedString(@"fileListLabelTextForDropBox", nil);
    dropboxPath = [dropboxPath stringByAppendingString:@": /Apps/iRollMusic"];
    
    self.titleLabel.text = dropboxPath;

    [self.tableView registerNib:[UINib nibWithNibName:@"DropboxFileListTableViewCell" bundle:nil] forCellReuseIdentifier:@"DropboxFileListTableViewCell"];
    self.tableView.rowHeight = 44.0;    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.activityIndicatorView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadFileListFromDropBox];
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

#pragma mark - Button Actions

- (IBAction)deleteFileFromDropbox:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"confirmDeleteFromDropboxAlertViewTitle", nil)
                                                                   message:MyLocalizedString(@"confirmDeleteFromDropboxAlertViewMessage", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                                                         if (indexPath != nil) {
                                                             TransferFile *transferFile;
                                                             if (self.searchPredicate == nil) {
                                                                 transferFile = [self.files objectAtIndex:indexPath.row];
                                                             } else {
                                                                 transferFile = [self.filteredFiles objectAtIndex:indexPath.row];
                                                             }
                                                             [self deleteTransferFile:transferFile];
                                                         }
                                                     }];
    [alert addAction:okAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteTransferFile:(TransferFile*)transferFile
{
    [self showActivityIndicator];
    DropboxFileDeleteOperation *dropboxFileDeleteOperation = [[DropboxFileDeleteOperation alloc] initWithDropboxFile:transferFile.dropboxFile];
    [dropboxFileDeleteOperation setCompletionBlockWithSuccess:^(NSString *filePath) {
        [self hideActivityIndicator];
        [self loadFileListFromDropBox];
        
    } failure:^(NSString *errorMessage) {
        [self hideActivityIndicator];
        if (errorMessage != nil) {
            [self presentViewController:[Helpers alertControllerWithTitle:nil message:errorMessage] animated:YES completion:nil];
        }
    }];
    [self.operationQueue addOperation:dropboxFileDeleteOperation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchPredicate == nil) {
        return [self.files count];
    } else {
        return [self.filteredFiles count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DropboxFileListTableViewCell *cell = (DropboxFileListTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"DropboxFileListTableViewCell" forIndexPath:indexPath];

    TransferFile *transferFile;
    if (self.searchPredicate == nil) {
        transferFile = [self.files objectAtIndex:indexPath.row];
    } else {
        transferFile = [self.filteredFiles objectAtIndex:indexPath.row];
    }

    [cell setupWithTransferFile:transferFile];
    [cell.addButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (nil == indexPath){
        return;
    } else {
        TransferFile *transferFile;
        if (self.searchPredicate == nil) {
            transferFile = [self.files objectAtIndex:indexPath.row];
        } else {
            transferFile = [self.filteredFiles objectAtIndex:indexPath.row];
        }
        
        NSNotification *notification = [NSNotification notificationWithName:kLibraryDropboxAddFileToTransferListNotification object:nil userInfo:@{kLibraryDropboxAddFileToTransferListNotificationObject: [transferFile copy]}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TransferFile *transferFile;
    if (self.searchPredicate == nil) {
        transferFile = [self.files objectAtIndex:indexPath.row];
    } else {
        transferFile = [self.filteredFiles objectAtIndex:indexPath.row];
    }
    [self deleteTransferFile:transferFile];
}


#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDeleteButtonStatus];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText == nil || searchText.length == 0) {
        self.searchPredicate = nil;
        self.filteredFiles = [NSArray array];
    } else {
        self.searchPredicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[cd] %@", searchText];
        self.filteredFiles = [self.files filteredArrayUsingPredicate:self.searchPredicate];
    }
    
    [self.tableView reloadData];
    [self updateDeleteButtonStatus];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
}

#pragma mark - Loading Remote Data

- (void)loadFileListFromDropBox
{
    [self showActivityIndicator];
    [[self.dbUserClient.filesRoutes listFolder:@""
                                     recursive:[NSNumber numberWithBool:0]
                              includeMediaInfo:[NSNumber numberWithBool:0]
                                includeDeleted:[NSNumber numberWithBool:0]
               includeHasExplicitSharedMembers:[NSNumber numberWithBool:0]]
     setResponseBlock:^(DBFILESListFolderResult * _Nullable result, DBFILESListFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result) {
            BOOL hasMore = [result.hasMore boolValue];
            if (hasMore) {
                NSLog(@"Folder is large enough where we need to call `listFolderContinue:`");
                NSString *cursor = result.cursor;
                [self listFolderContinueWithClient:self.dbUserClient cursor:cursor];
            } else {
                NSLog(@"List folder complete.");
                NSArray<DBFILESMetadata *> *files = result.entries;
                [self loadedFileListFromDropbox:files];
                [self hideActivityIndicator];
            }
        }  else {
            NSLog(@"%@\n%@\n", routeError, networkError);
        }
    }];
}

- (void)listFolderContinueWithClient:(DBUserClient *)client cursor:(NSString *)cursor {
    [[client.filesRoutes listFolderContinue:cursor]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderContinueError *routeError,
                        DBRequestError *networkError) {
         if (result) {
             BOOL hasMore = [result.hasMore boolValue];
             
             if (hasMore) {
                 NSLog(@"Folder is large enough where we need to call `listFolderContinue:`");
                 NSString *cursor = result.cursor;
                 [self listFolderContinueWithClient:client cursor:cursor];
             } else {
                 NSLog(@"List folder complete.");
                 NSArray<DBFILESMetadata *> *files = result.entries;
                 [self loadedFileListFromDropbox:files];
                 [self hideActivityIndicator];
             }
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}


- (void)loadedFileListFromDropbox:(NSArray<DBFILESMetadata *>*)filesMetaData
{
    NSMutableArray *newFiles = [NSMutableArray array];
    
    for (DBFILESMetadata *item in filesMetaData) {
        if ([item isKindOfClass:[DBFILESFileMetadata class]]) {
            DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata*) item;
            if ([[fileMetadata.pathLower pathExtension] isEqualToString:kScoreBlitzFileExtension] ||
                [[fileMetadata.pathLower pathExtension] isEqualToString:kPdfFileExtension]) {
                TransferFile *newTransferFile = [[TransferFile alloc] initWithDropBoxFile:fileMetadata];
                [newFiles addObject:newTransferFile];
            }
        }
    }
    
    self.files = [self.files arrayByAddingObjectsFromArray:newFiles];
    [self.tableView reloadData];
    [self updateDeleteButtonStatus];
}

#pragma mark - Activity Indicator Handling

- (void)showActivityIndicator
{
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}


- (void)hideActivityIndicator
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

/*
#pragma mark - DBSessionDelegate

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    [session unlinkUserId:userId];
    [[DBSession sharedSession] linkFromController:self];
}

#pragma mark -
#pragma mark DBRestClient delegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    if ([client isEqual:self.dbRestClient]) {
        [self loadedFileListFromDropbox:metadata];
    }
    [self hideActivityIndicator];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
    
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    [self hideActivityIndicator];
#ifdef DEBUG
    NSLog(@"%s: %@: %@", __func__, error, [error userInfo]);
#endif
}*/


@end
