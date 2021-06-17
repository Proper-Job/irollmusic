//
//  SetEditViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import "SetEditViewController.h"
#import "ScoreBlitzAppDelegate.h"
#import "ScoreManager.h"
#import "SetEditTableViewCell.h"

@interface SetEditViewController ()

@end

@implementation SetEditViewController

- (id)initWithSet:(Set*)set
{
    self = [super initWithNibName:@"SetEditViewController" bundle:nil];
    if (self != nil) {
        self.setList = set;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"SetEditTableViewCell" bundle:nil] forCellReuseIdentifier:@"SetEditTableViewCell"];
    
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

#pragma mark -
#pragma mark Table view data source

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
    
    SetEditTableViewCell *cell = (SetEditTableViewCell*)[self.tableview dequeueReusableCellWithIdentifier:@"SetEditTableViewCell" forIndexPath:indexPath];
    
    Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupWithScore:score];
    [cell.addScoreButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:[[[event touchesForView: button] anyObject] locationInView: self.tableview]];
    if (nil == indexPath){
        return;
    } else {
        [self.tableview.delegate tableView: self.tableview accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [[ScoreManager sharedInstance] addSetListEntryToSet:self.setList score:score];
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
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
    
    [self.tableview reloadData];
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
    [self.tableview reloadData];
}

@end
