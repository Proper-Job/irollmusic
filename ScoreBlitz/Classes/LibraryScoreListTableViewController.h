//
//  LibraryScoreListTableViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 01.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreActionsTableViewController.h"

@class Score;

@interface LibraryScoreListTableViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, ScoreActionsTableViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableview;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton, *dropboxButton, *analyzeAllScoresButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)deleteButtonTapped;
- (IBAction)showDropBox;

- (void)deleteScore:(Score *)score;

@end
