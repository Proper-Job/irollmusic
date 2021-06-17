//
//  SetDetailViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import "SetDetailViewController.h"
#import "ScoreBlitzAppDelegate.h"
#import "ScoreManager.h"
#import "SetDetailTableViewCell.h"
#import "Set.h"
#import "SetListEntry.h"
#import "SetDetailTableHeaderView.h"

@interface SetDetailViewController ()

@end

@implementation SetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(librarySetListSelectionDidChange:) name:kLibrarySetListSelectionDidChange object:nil];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"SetDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"SetDetailTableViewCell"];
    [[NSBundle mainBundle] loadNibNamed:@"SetDetailTableHeaderView" owner:self options:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Setup fetchedResultsController
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SetListEntry"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:UIAppDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)editTapped:(id)sender
{
    if (self.tableview.isEditing) {
        [self.tableview setEditing:NO animated:YES];
        self.tableview.tableHeaderView = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryHideEditSetViewController object:nil];
        
        self.setList.name = self.setDetailTableHeaderView.setTitleTextField.text;
        [[ScoreManager sharedInstance] saveTheFuckingContext];        
    } else {
        [self.tableview setEditing:YES animated:YES];
        self.tableview.tableHeaderView = self.setDetailTableHeaderView;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLibraryShowEditSetViewController object:nil userInfo:@{kLibraryShowEditSetViewControllerObjectKey: self.setList}]];
    }
}

#pragma mark - Table view data source

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
    
    SetDetailTableViewCell *cell = (SetDetailTableViewCell*)[self.tableview dequeueReusableCellWithIdentifier:@"SetDetailTableViewCell" forIndexPath:indexPath];
    
    SetListEntry *setListEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupWithSetListEntry:setListEntry];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SetListEntry *setListEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[ScoreManager sharedInstance] removeSetListEntry:setListEntry];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    SetListEntry *setListEntry = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    
    // set rank of from object to rank of to object
    [[ScoreManager sharedInstance] moveSetListEntry:setListEntry fromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.setDetailTableHeaderView.playtimeLabel.text = [self.setList playTimeString];
    [self.tableview reloadData];
}

#pragma mark - Notifications

- (void)librarySetListSelectionDidChange:(NSNotification*)notification
{
    self.setList = [[notification userInfo] objectForKey:kLibrarySetListSelectionDidChangeObjectKey];

    if (self.setList == nil) {
        self.editButton.enabled = NO;
        self.setDetailTableHeaderView.setTitleTextField.text = @"";
        self.setDetailTableHeaderView.playtimeLabel.text = @"";
    } else {
        self.editButton.enabled = YES;
        self.setDetailTableHeaderView.setTitleTextField.text = self.setList.name;
        self.setDetailTableHeaderView.playtimeLabel.text = [self.setList playTimeString];
    }
    
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"setList == %@", self.setList];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error] && APP_DEBUG) {
        NSLog(@"Error fetching Resort List Items: %@ %s %d", error.localizedDescription, __func__, __LINE__);
    }
    [self.tableview reloadData];
}


@end
