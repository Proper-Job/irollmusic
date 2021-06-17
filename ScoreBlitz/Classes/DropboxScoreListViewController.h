//
//  DropboxScoreListViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import <UIKit/UIKit.h>

@interface DropboxScoreListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
