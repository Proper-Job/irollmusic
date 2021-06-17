//
//  DropboxRemoteFilesSearchResultsTableViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 08.01.15.
//
//

#import "DropboxRemoteFilesSearchResultsTableViewController.h"
#import "DropboxFileListTableViewCell.h"
#import "TransferFile.h"

@interface DropboxRemoteFilesSearchResultsTableViewController ()

@end

@implementation DropboxRemoteFilesSearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DropboxFileListTableViewCell" bundle:nil] forCellReuseIdentifier:@"DropboxFileListTableViewCell"];
    self.tableView.rowHeight = 44.0;
    self.automaticallyAdjustsScrollViewInsets = NO;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DropboxFileListTableViewCell *cell = (DropboxFileListTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"DropboxFileListTableViewCell" forIndexPath:indexPath];
    
    TransferFile *transferFile = [self.filteredFiles objectAtIndex:indexPath.row];
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
        TransferFile *transferFile = [self.filteredFiles objectAtIndex:indexPath.row];
        
        NSNotification *notification = [NSNotification notificationWithName:kLibraryDropboxAddFileToTransferListNotification object:nil userInfo:@{kLibraryDropboxAddFileToTransferListNotificationObject: transferFile}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}


@end
