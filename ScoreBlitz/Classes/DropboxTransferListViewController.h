//
//  DropboxTransferListViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import <UIKit/UIKit.h>

@interface DropboxTransferListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel, *transferVolumeLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *startTransferButton, *deleteButton, *clearTransferListButton;

@property (nonatomic, strong) NSMutableArray*transferToDropboxFiles, *transferToIrollMusicFiles;

- (IBAction)deleteFileFromTransferListTapped;
- (IBAction)clearTransferListTapped;

@end
