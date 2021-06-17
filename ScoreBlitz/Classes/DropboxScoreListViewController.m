//
//  DropboxScoreListViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import "DropboxScoreListViewController.h"
#import "DropboxScoreListTableViewCell.h"
#import "ScoreBlitzAppDelegate.h"
#import "Score.h"
#import "TransferFile.h"

@interface DropboxScoreListViewController ()

@end

@implementation DropboxScoreListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = MyLocalizedString(@"fileListLabelTextForIrollmusic", nil);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DropboxScoreListTableViewCell" bundle:nil] forCellReuseIdentifier:@"DropboxScoreListTableViewCell"];
    self.tableView.rowHeight = 44.0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Setup fetchedResultsController
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:UIAppDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error] && APP_DEBUG) {
        NSLog(@"Error fetching Resort List Items: %@ %s %d", error.localizedDescription, __func__, __LINE__);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DropboxScoreListTableViewCell *cell = (DropboxScoreListTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"DropboxScoreListTableViewCell" forIndexPath:indexPath];
    
    Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupWithScore:score];
    [cell.addButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (nil == indexPath){
        return;
    } else {
        Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
        TransferFile *transferFile = [[TransferFile alloc] initWithScore:score];
        
        NSNotification *notification = [NSNotification notificationWithName:kLibraryDropboxAddFileToTransferListNotification object:nil userInfo:@{kLibraryDropboxAddFileToTransferListNotificationObject: [transferFile copy]}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
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
        self.fetchedResultsController.fetchRequest.predicate = nil;
    } else {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        self.fetchedResultsController.fetchRequest.predicate = searchPredicate;
    }
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error] && APP_DEBUG) {
        NSLog(@"Error fetching Resort List Items: %@ %s %d", error.localizedDescription, __func__, __LINE__);
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

@end
