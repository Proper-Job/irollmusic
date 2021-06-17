//
//  NewLibraryViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import "NewLibraryViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "LibraryScoreListTableViewController.h"
#import "ScoreDetailTableViewController.h"
#import "SetListViewController.h"
#import "SetDetailViewController.h"
#import "SetEditViewController.h"
#import "PureLayout.h"
#import "NewDropboxViewController.h"

@interface NewLibraryViewController ()

@end

@implementation NewLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSetEditViewController:) name:kLibraryShowEditSetViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSetEditViewController:) name:kLibraryHideEditSetViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDropboxViewController:) name:kLibraryShowDropboxViewController object:nil];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                  [NSArray arrayWithObjects:MyLocalizedString(@"libraryModelTypeScores", nil),
                                   MyLocalizedString(@"libraryModelTypeSets", nil), nil]];
    [self.segmentedControl addTarget:self action:@selector(toogleDisplayType) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *segmentedButton = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
    
    [self.navigationItem setRightBarButtonItem:segmentedButton];
    
    self.libraryDisplayType = LibraryDisplayTypeScores;
    self.segmentedControl.selectedSegmentIndex = self.libraryDisplayType;

    self.leftViewController = [[LibraryScoreListTableViewController alloc] initWithNibName:@"LibraryScoreListTableViewController" bundle:nil];
    self.rightViewController = [[ScoreDetailTableViewController alloc] initWithNibName:@"ScoreDetailTableViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.rightViewController];
    navigationController.navigationBarHidden = YES;
    navigationController.toolbarHidden = NO;
    
    self.librarySplitViewController = [[UISplitViewController alloc] init];
    self.librarySplitViewController.viewControllers = @[self.leftViewController, navigationController];
    self.librarySplitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.librarySplitViewController.maximumPrimaryColumnWidth = self.view.bounds.size.width;
    self.librarySplitViewController.preferredPrimaryColumnWidthFraction = 0.5;
    self.librarySplitViewController.delegate = self;

    [self addChildViewController:self.librarySplitViewController];
    [self.view addSubview:self.librarySplitViewController.view];
    [self.librarySplitViewController didMoveToParentViewController:self];
    
    [self.librarySplitViewController.view autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [self.librarySplitViewController.view autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.librarySplitViewController.view autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.librarySplitViewController.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDropBoxViewController
{
    NewDropboxViewController *dropboxViewController = [[NewDropboxViewController alloc] initWithNibName:@"NewDropboxViewController" bundle:nil];
    [self.navigationController pushViewController:dropboxViewController animated:YES];
}

#pragma mark - Button Actions

- (void)toogleDisplayType
{
    if (self.segmentedControl.selectedSegmentIndex == LibraryDisplayTypeScores) {
        self.leftViewController = [[LibraryScoreListTableViewController alloc] initWithNibName:@"LibraryScoreListTableViewController" bundle:nil];
        self.rightViewController = [[ScoreDetailTableViewController alloc] initWithNibName:@"ScoreDetailTableViewController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.rightViewController];
        navigationController.navigationBarHidden = YES;
        navigationController.toolbarHidden = NO;
        
        self.librarySplitViewController.viewControllers = @[self.leftViewController, navigationController];
    } else {
        self.leftViewController = [[SetListViewController alloc] initWithNibName:@"SetListViewController" bundle:nil];
        self.rightViewController = [[SetDetailViewController alloc] initWithNibName:@"SetDetailViewController" bundle:nil];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.leftViewController];
        navigationController.navigationBarHidden = YES;
        
        self.librarySplitViewController.viewControllers = @[navigationController, self.rightViewController];
    }
}

#pragma mark - Notifications

- (void)showSetEditViewController:(NSNotification*)notification
{
    Set *setList = [[notification userInfo] objectForKey:kLibraryShowEditSetViewControllerObjectKey];
    SetEditViewController *setEditViewController = [[SetEditViewController alloc] initWithSet:setList];
    [self.leftViewController.navigationController pushViewController:setEditViewController animated:YES];
}

- (void)hideSetEditViewController:(NSNotification*)notification
{
    [self.leftViewController.navigationController popViewControllerAnimated:YES];
}

- (void)showDropboxViewController:(NSNotification*)notification
{
    // check if dropBox access token is present, otherwise login
    if ([DBClientsManager authorizedClient] == nil) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }];
    } else {
        [self showDropBoxViewController];
    }
}

@end
