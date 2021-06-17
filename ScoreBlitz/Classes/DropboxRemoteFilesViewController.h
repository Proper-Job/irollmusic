//
//  DropboxRemoteFilesViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import <UIKit/UIKit.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface DropboxRemoteFilesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) NSArray *files, *filteredFiles;
@property (nonatomic, strong) DBUserClient *dbUserClient;
@property (nonatomic, strong) NSPredicate *searchPredicate;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end
