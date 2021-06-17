//
//  SetListViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import "SetListViewController.h"
#import "ScoreBlitzAppDelegate.h"
#import "SetTableViewCell.h"
#import "Set.h"
#import "Score.h"
#import "PerformancePagingViewController.h"
#import "PerformanceScrollingViewController.h"
#import "ScoreManager.h"
#import "ScoreAnalysingViewController.h"
#import "MZFormSheetPresentationController.h"

@interface SetListViewController ()

@end

@implementation SetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"SetTableViewCell" bundle:nil] forCellReuseIdentifier:@"SetTableViewCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    // Setup fetchedResultsController
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Set"];
    
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
#pragma mark Button actions


- (IBAction)deleteButtonTapped
{
    NSIndexPath *indexPath = [self.tableview indexPathForSelectedRow];
    
    if (indexPath != nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"confirmDeleteSetTitle", nil)
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
                                                             if (indexPath != nil) {
                                                                 Set *set = [self.fetchedResultsController objectAtIndexPath:indexPath];
                                                                 [[UIAppDelegate managedObjectContext] deleteObject:set];
                                                                 [[ScoreManager sharedInstance] saveTheFuckingContext];
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

- (IBAction)addSetTapped:(id)sender
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"libraryAddSetListTitle", nil)
                                                                   message:MyLocalizedString(@"libraryAddSetListTitleMessage", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         NSString *setTitle = [[alertController.textFields firstObject] text];
                                                         if (setTitle != nil) {
                                                             Set *setList = (Set *) [[NSManagedObject alloc] initWithEntity:[Set entityDescription]
                                                                                                  insertIntoManagedObjectContext:[UIAppDelegate managedObjectContext]];
                                                             setList.name = setTitle;
                                                             [UIAppDelegate saveContext];
                                                         }
                                                     }];
    [alertController addAction:okAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
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
    
    SetTableViewCell *cell = (SetTableViewCell*)[self.tableview dequeueReusableCellWithIdentifier:@"SetTableViewCell" forIndexPath:indexPath];
    
    Set *set = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupWithSet:set];
    [cell.playButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:[[[event touchesForView: button] anyObject] locationInView: self.tableview]];
    if (nil == indexPath){
        return;
    } else {
        Set *setList = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSArray *unAnalyzedScores = [setList unAnalyzedScores];
        
        if ([unAnalyzedScores count] > 0) {
            // Start Analysing
            ScoreAnalysingViewController *scoreAnalysingViewController = [[ScoreAnalysingViewController alloc] initWithScores:unAnalyzedScores];
            [scoreAnalysingViewController setCompletionBlock:^(BOOL success) {
                if (success) {
                    NSArray *setListEntries = [setList orderedSetListEntriesAsc];
                    Score *score = [[setListEntries firstObject] score];
                    
                    PerformanceMode performanceMode = [score.preferredPerformanceMode intValue];
                    PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
                    
                    UIViewController *viewController;
                    if (performanceMode == PerformanceModePage) {
                        viewController = [[PerformancePagingViewController alloc] initWithSet:setList
                                                                                        score:score
                                                                                         page:nil];
                    } else {
                        viewController = [[PerformanceScrollingViewController alloc] initWithSet:setList
                                                                                           score:score
                                                                                            page:nil
                                                                                 performanceMode:scrollMode];
                    }
                    
                    [self.splitViewController.navigationController pushViewController:viewController animated:YES];
                    [[ScoreManager sharedInstance] pushScoreToRecentList:score];
                    [[ScoreManager sharedInstance] pushSetToRecentList:setList];
                }
            }];
            
            MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:scoreAnalysingViewController];
            formSheet.shouldCenterVertically = YES;
            
            [self presentViewController:formSheet animated:YES completion:nil];
        } else {
            NSArray *setListEntries = [setList orderedSetListEntriesAsc];
            Score *score = [[setListEntries firstObject] score];

            PerformanceMode performanceMode = [score.preferredPerformanceMode intValue];
            PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
            
            UIViewController *viewController;
            if (performanceMode == PerformanceModePage) {
                viewController = [[PerformancePagingViewController alloc] initWithSet:setList
                                                                                score:score
                                                                                 page:nil];
            } else {
                viewController = [[PerformanceScrollingViewController alloc] initWithSet:setList
                                                                                   score:score
                                                                                    page:nil
                                                                         performanceMode:scrollMode];
            }
            
            [self.splitViewController.navigationController pushViewController:viewController animated:YES];
            [[ScoreManager sharedInstance] pushScoreToRecentList:score];
            [[ScoreManager sharedInstance] pushSetToRecentList:setList];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Set *set = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[UIAppDelegate managedObjectContext] deleteObject:set];
        [[ScoreManager sharedInstance] saveTheFuckingContext];
    }
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Set *set = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLibrarySetListSelectionDidChange object:nil userInfo:@{kLibrarySetListSelectionDidChangeObjectKey: set}]];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableview reloadData];
}

@end
