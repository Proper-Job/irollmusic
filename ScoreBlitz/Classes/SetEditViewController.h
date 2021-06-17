//
//  SetEditViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import <UIKit/UIKit.h>

@class Set;

@interface SetEditViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableview;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Set *setList;

- (id)initWithSet:(Set*)set;

@end
