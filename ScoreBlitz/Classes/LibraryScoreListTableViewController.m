//
//  LibraryScoreListTableViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 01.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "LibraryScoreListTableViewController.h"
#import "ScoreBlitzAppDelegate.h"
#import "CentralViewController.h"
#import "ScoreManager.h"
#import "ScoreTableViewCell.h"
#import "Score.h"
#import "PerformancePagingViewController.h"
#import "PerformanceScrollingViewController.h"
#import "ScoreAnalysingViewController.h"
#import "MZFormSheetPresentationController.h"
#import "QueryHelper.h"
#import "FileImportViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@implementation LibraryScoreListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"ScoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScoreTableViewCell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *dropboxLogo = [[UIImage imageNamed:@"dropbox-logo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.dropboxButton = [[UIBarButtonItem alloc] initWithImage:dropboxLogo style:UIBarButtonItemStylePlain target:self action:@selector(showDropBox)];
    
    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 15.0;
    
    UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped:)];
    
    self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonTapped)];
    
    self.bottomToolbar.items = @[self.deleteButton, flexibleSpaceBarButtonItem, self.dropboxButton, fixedSpaceBarButtonItem, actionBarButtonItem];
    
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



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateDeleteButtonStatus];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self selectFirstTableViewRow];
}

#pragma mark - View Updates

- (void)updateDeleteButtonStatus
{
    if ([self.tableview indexPathForSelectedRow]) {
        self.deleteButton.enabled = YES;
    } else {
        self.deleteButton.enabled = NO;
    }
}

- (void)selectFirstTableViewRow
{
    NSIndexPath *selection = [self.tableview indexPathForSelectedRow];
    if (selection == nil && [self.fetchedResultsController.fetchedObjects count] > 0) {
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableview selectRowAtIndexPath:firstIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tableview.delegate tableView:self.tableview didSelectRowAtIndexPath:firstIndexPath];
    }
}


#pragma mark - Data operations

- (void)deleteScore:(Score *)score
{
    [[UIAppDelegate managedObjectContext] deleteObject:score];
    [[ScoreManager sharedInstance] saveTheFuckingContext];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLibraryScoreListSelectionDidChange object:nil userInfo:nil]];
}

- (void)deleteAllScoresDataOperation
{
    NSArray *allScores = [QueryHelper allScores];
    
    if (allScores != nil) {
        for (Score *score in allScores) {
            [[ScoreManager sharedInstance] deleteScore:score];
        }
        [[ScoreManager sharedInstance] saveTheFuckingContext];
    }
}

#pragma mark -
#pragma mark Button actions


- (IBAction)deleteButtonTapped
{
    NSIndexPath *indexPath = [self.tableview indexPathForSelectedRow];
    
    if (indexPath != nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"confirmDeleteScoreTitle", nil)
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
                                                             if (indexPath != nil) {
                                                                 Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
                                                                 [self deleteScore:score];
                                                             }
                                                         }];
        [alert addAction:okAction];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {}];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)showDropBox
{    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryShowDropboxViewController object:nil];
}

- (IBAction)actionTapped:(id)sender
{
    UIBarButtonItem *barButtonItem = (UIBarButtonItem*)sender;
    ScoreActionsTableViewController *scoreActionsTableViewController = [[ScoreActionsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    scoreActionsTableViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:scoreActionsTableViewController];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
    UIPopoverPresentationController *presentationController = [navigationController popoverPresentationController];
    presentationController.barButtonItem = barButtonItem;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
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
	
    ScoreTableViewCell *cell = (ScoreTableViewCell*)[self.tableview dequeueReusableCellWithIdentifier:@"ScoreTableViewCell" forIndexPath:indexPath];
    
    Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupWithScore:score];
    [cell.playButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:[[[event touchesForView: button] anyObject] locationInView:self.tableview]];
    if (nil == indexPath){
        return;
    } else {
        Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([score.isAnalyzed boolValue]) {
            PerformanceMode performanceMode = [score.preferredPerformanceMode intValue];
            PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
            
            UIViewController *viewController;
            if (performanceMode == PerformanceModePage) {
                viewController = [[PerformancePagingViewController alloc] initWithSet:nil
                                                                                score:score
                                                                                 page:nil];
            } else {
                viewController = [[PerformanceScrollingViewController alloc] initWithSet:nil
                                                                                   score:score
                                                                                    page:nil
                                                                         performanceMode:scrollMode];
            }
            
            [self.navigationController pushViewController:viewController animated:YES];
            [[ScoreManager sharedInstance] pushScoreToRecentList:score];            
            
        } else {
            // Start Analysing
            ScoreAnalysingViewController *scoreAnalysingViewController = [[ScoreAnalysingViewController alloc] initWithScores:@[score]];
            [scoreAnalysingViewController setCompletionBlock:^(BOOL success) {
                if (success) {
                    PerformanceMode performanceMode = [score.preferredPerformanceMode intValue];
                    PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
                    
                    UIViewController *viewController;
                    if (performanceMode == PerformanceModePage) {
                        viewController = [[PerformancePagingViewController alloc] initWithSet:nil
                                                                                        score:score
                                                                                         page:nil];
                    } else {
                        viewController = [[PerformanceScrollingViewController alloc] initWithSet:nil
                                                                                           score:score
                                                                                            page:nil
                                                                                 performanceMode:scrollMode];
                    }
                    
                    [self.navigationController pushViewController:viewController animated:YES];
                    [[ScoreManager sharedInstance] pushScoreToRecentList:score];
                }
            }];
            
            MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:scoreAnalysingViewController];
            formSheet.shouldCenterVertically = YES;
            
            [self presentViewController:formSheet animated:YES completion:nil];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   if (editingStyle == UITableViewCellEditingStyleDelete) {
       Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];
       [self deleteScore:score];
   }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Score *score = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLibraryScoreListSelectionDidChange
                                                                                         object:nil
                                                                                       userInfo:@{kLibraryScoreListSelectionDidChangeObjectKey: score}]];
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


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSIndexPath *selection = [self.tableview indexPathForSelectedRow];
    [self.tableview reloadData];
    
    if (nil != selection) {
        [self.tableview selectRowAtIndexPath:selection animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    [self updateDeleteButtonStatus];
}

#pragma mark - ScoreActionsTableViewControllerDelegate

- (void)analyseAllScores
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isAnalyzed == %@", [NSNumber numberWithBool:NO]]];

    NSError *error = nil;
    NSArray *allUnanalysedScores = [UIAppDelegate.managedObjectContext executeFetchRequest:request error:&error];

    if (nil != error && APP_DEBUG) {
        NSLog(@"%@ %s %d", [error localizedDescription], __func__, __LINE__);
    }
    
    if ([allUnanalysedScores count] > 0) {
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        UIDeviceBatteryState state = device.batteryState;
        float batteryLevel = device.batteryLevel;
        device.batteryMonitoringEnabled = NO;
        
        if (UIDeviceBatteryStateUnplugged == state && batteryLevel < .2) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"powerSourceUnpluggedTitle", nil)
                                                                           message:MyLocalizedString(@"powerSourceUnpluggedMessage", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonContinue", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 // Start Analysing
                                                                 ScoreAnalysingViewController *scoreAnalysingViewController = [[ScoreAnalysingViewController alloc] initWithScores:allUnanalysedScores];
                                                                 
                                                                 MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController: scoreAnalysingViewController];
                                                                 formSheet.shouldCenterVertically = YES;
                                                                 
                                                                 [self presentViewController:formSheet animated:YES completion:nil];
                                                             }];
            [alert addAction:okAction];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {}];
            [alert addAction:cancelAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // Start Analysing
            ScoreAnalysingViewController *scoreAnalysingViewController = [[ScoreAnalysingViewController alloc] initWithScores:allUnanalysedScores];
            
            MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:scoreAnalysingViewController];
            formSheet.shouldCenterVertically = YES;
            
            [self presentViewController:formSheet animated:YES completion:nil];
        }
    }
}

- (void)deleteAllScores
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"DeleteAllScoresAlertControllerTitle", nil)
                                                                   message:MyLocalizedString(@"DeleteAllScoresAlertControllerMessage", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * action) {
                                                         [self deleteAllScoresDataOperation];
                                                     }];
    [alert addAction:okAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkDocumentsDirectory
{
    NSArray *pdfFilePaths = [FileImportViewController pdfFilePaths];
    NSArray *irmFilePaths = [FileImportViewController irmFilePaths];
    NSInteger numberOfFiles = [pdfFilePaths count] + [irmFilePaths count];
    
    if (numberOfFiles > 0) {
        FileImportViewController *fileImportViewController = [[FileImportViewController alloc] initWithFilePaths:pdfFilePaths irmFilePaths:irmFilePaths];
        MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:fileImportViewController];
        formSheet.shouldCenterVertically = YES;
        
        [self presentViewController:formSheet animated:YES completion:nil];
    }
}

- (void)linkDropbox
{
    if ([DBClientsManager authorizedClient] == nil) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }];
    }
}

- (void)unlinkDropbox
{
    if ([DBClientsManager authorizedClient] != nil) {
        [DBClientsManager unlinkAndResetClients];
    }
}

@end

