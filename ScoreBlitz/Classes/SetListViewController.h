//
//  SetListViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import <UIKit/UIKit.h>

@interface SetListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableview;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton, *addButton;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)deleteButtonTapped;
- (IBAction)addSetTapped:(id)sender;

@end
