//
//  SetDetailViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 04.09.14.
//
//

#import <UIKit/UIKit.h>

@class Set, SetDetailTableHeaderView;

@interface SetDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *playtimeLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableview;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet SetDetailTableHeaderView *setDetailTableHeaderView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Set *setList;

- (IBAction)editTapped:(id)sender;

@end
