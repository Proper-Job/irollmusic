//
//  NewDropboxViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    DropboxDisplayTypeDropbox,
    DropboxDisplayTypeLocal    
} DropboxDisplayType;

@class DropboxRemoteFilesViewController, DropboxScoreListViewController, DropboxTransferListViewController;

@interface NewDropboxViewController : UIViewController

@property (nonatomic, strong) UISegmentedControl *transferSelector;
@property (nonatomic, strong) UISplitViewController *dropboxSplitViewController;
@property (nonatomic, strong) UIViewController *leftViewController, *rightViewController;
@property (nonatomic, strong) DropboxRemoteFilesViewController *dropboxRemoteFilesViewController;
@property (nonatomic, strong) DropboxScoreListViewController *dropboxScoreListViewController;
@property (nonatomic, strong) DropboxTransferListViewController *dropboxTransferListViewController;


@property (nonatomic, assign) DropboxDisplayType dropboxDisplayType;

@end
