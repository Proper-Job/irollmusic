//
//  NewDropboxViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import "NewDropboxViewController.h"
#import "PureLayout.h"
#import "DropboxScoreListViewController.h"
#import "DropboxRemoteFilesViewController.h"
#import "DropboxTransferListViewController.h"

@interface NewDropboxViewController ()

@end

@implementation NewDropboxViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.transferSelector = [[UISegmentedControl alloc] initWithItems:@[MyLocalizedString(@"dropboxSegmentTitle", nil), MyLocalizedString(@"iRollMusicSegmentTitle", nil)]];
    [self.transferSelector addTarget:self action:@selector(toogleDisplayType) forControlEvents:UIControlEventValueChanged];
    self.transferSelector.selectedSegmentIndex = DropboxDisplayTypeDropbox;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.transferSelector];
        
    self.dropboxScoreListViewController = [[DropboxScoreListViewController alloc] initWithNibName:@"DropboxScoreListViewController" bundle:nil];
    self.dropboxRemoteFilesViewController = [[DropboxRemoteFilesViewController alloc] initWithNibName:@"DropboxRemoteFilesViewController" bundle:nil];
    self.dropboxTransferListViewController = [[DropboxTransferListViewController alloc] initWithNibName:@"DropboxTransferListViewController" bundle:nil];
    
    self.dropboxSplitViewController = [[UISplitViewController alloc] init];
    self.dropboxSplitViewController.viewControllers = @[self.dropboxRemoteFilesViewController, self.dropboxTransferListViewController];
    self.dropboxSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.dropboxSplitViewController.maximumPrimaryColumnWidth = self.view.bounds.size.width;
    self.dropboxSplitViewController.preferredPrimaryColumnWidthFraction = 0.5;
    
    [self addChildViewController:self.dropboxSplitViewController];
    [self.view addSubview:self.dropboxSplitViewController.view];
    [self.dropboxSplitViewController didMoveToParentViewController:self];
    
    [self.dropboxSplitViewController.view autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [self.dropboxSplitViewController.view autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.dropboxSplitViewController.view autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.dropboxSplitViewController.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (void)toogleDisplayType
{
    if (self.transferSelector.selectedSegmentIndex == DropboxDisplayTypeLocal) {
        self.dropboxSplitViewController.viewControllers = @[self.dropboxScoreListViewController, self.dropboxTransferListViewController];
    } else {
        self.dropboxSplitViewController.viewControllers = @[self.dropboxRemoteFilesViewController, self.dropboxTransferListViewController];
    }
}

@end
