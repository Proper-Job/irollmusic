    //
//  CentralViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import "CentralViewController.h"
#import "TutorialViewController.h"
#import "SettingsViewController.h"
#import "Set.h"
#import "SetListEntry.h"
#import "RecentScoreList.h"
#import "RecentScoreListEntry.h"
#import "RecentSetList.h"
#import "RecentSetListEntry.h"
#import "Score.h"
#import "Page.h"
#import "ScoreBlitzAppDelegate.h"
#import "ScoreManager.h"
#import "SettingsManager.h"
#import "PerformancePagingViewController.h"
#import "PerformanceScrollingViewController.h"
#import "Commons.h"
#import "EditorViewController.h"
#import "TrackingManager.h"
#import "BrowserViewController.h"
#import "ScoreCollectionViewCell.h"
#import "SetCollectionViewCell.h"
#import "APCheckedLabel.h"
#import "NewLibraryViewController.h"
#import "MZFormSheetPresentationController.h"
#import "ScoreAnalysingViewController.h"
#import "PureLayout.h"

@implementation CentralViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged) name:kLanguageChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinischCopyingDefaultData) name:kDidFinischCopyingDefaultData object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scoreDidRotate:) name:kScoreDidRotateNotification object:nil];
    }
    return self;
}

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.view.backgroundColor = [Helpers black];
    
    [self.scoreCollectionView registerNib:[UINib nibWithNibName:@"ScoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ScoreCollectionViewCell"];
    [self.setCollectionView registerNib:[UINib nibWithNibName:@"SetCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SetCollectionViewCell"];
    
    // Setup Score FetchedResultsController
    NSFetchRequest *scoreFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"RecentScoreListEntry"];
    [scoreFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES]]];
    
    self.scoreFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:scoreFetchRequest
                                                                        managedObjectContext:[UIAppDelegate managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.scoreFetchedResultsController.delegate = self;
    
    NSError *scoreError = nil;
    if (![self.scoreFetchedResultsController performFetch:&scoreError] && APP_DEBUG) {
        NSLog(@"Error fetching Resort List Items: %@ %s %d", scoreError.localizedDescription, __func__, __LINE__);
    }

    // Setup Set FetchedResultsController
    NSFetchRequest *setFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"RecentSetListEntry"];
    [setFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES]]];
    
    self.setFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:setFetchRequest
                                                                             managedObjectContext:[UIAppDelegate managedObjectContext]
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:nil];
    self.setFetchedResultsController.delegate = self;
    
    NSError *setError = nil;
    if (![self.setFetchedResultsController performFetch:&setError] && APP_DEBUG) {
        NSLog(@"Error fetching Resort List Items: %@ %s %d", setError.localizedDescription, __func__, __LINE__);
    }
    
    // set the button descriptions
    [self languageChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UIAppDelegate.isCopyingDefaultData) {
        [self showActivityIndicator];
    }
    
    [self.scoreCollectionView reloadData];
    [self.setCollectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
    
    [[TrackingManager sharedInstance] trackGoogleViewWithIdentifier:[NSString stringWithFormat:@"%@", [self class]]];
}

#pragma mark - ViewController setup

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([collectionView isEqual:self.scoreCollectionView]) {
        return [self.scoreFetchedResultsController.sections count];
    } else {
        return [self.setFetchedResultsController.sections count];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.scoreCollectionView]) {
        return [[self.scoreFetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    } else {
        return [[self.setFetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.scoreCollectionView]) {
        ScoreCollectionViewCell *scoreCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScoreCollectionViewCell" forIndexPath:indexPath];
        RecentScoreListEntry *recentScoreListEntry = [self.scoreFetchedResultsController objectAtIndexPath:indexPath];
        [scoreCollectionViewCell setupWithRecentScoreListEntry:recentScoreListEntry];
        return scoreCollectionViewCell;
    } else {
        SetCollectionViewCell *setCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SetCollectionViewCell" forIndexPath:indexPath];
        RecentSetListEntry *recentSetListEntry = [self.setFetchedResultsController objectAtIndexPath:indexPath];
        [setCollectionViewCell setupWithRecentSetListEntry:recentSetListEntry];
        return setCollectionViewCell;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.scoreCollectionView]) {
        RecentScoreListEntry *recentScoreListEntry = [self.scoreFetchedResultsController objectAtIndexPath:indexPath];

        if ([recentScoreListEntry.score.isAnalyzed boolValue]) {
            PerformanceMode performanceMode = [recentScoreListEntry.score.preferredPerformanceMode intValue];
            PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
            
            UIViewController *viewController;
            if (performanceMode == PerformanceModePage) {
                viewController = [[PerformancePagingViewController alloc] initWithSet:nil
                                                                                score:recentScoreListEntry.score
                                                                                 page:nil];
            } else {
                viewController = [[PerformanceScrollingViewController alloc] initWithSet:nil
                                                                                   score:recentScoreListEntry.score
                                                                                    page:nil
                                                                         performanceMode:scrollMode];
            }
            
            [self.navigationController pushViewController:viewController animated:YES];
            [[ScoreManager sharedInstance] pushScoreToRecentList:recentScoreListEntry.score];
            
        } else {
            // Start Analysing
            ScoreAnalysingViewController *scoreAnalysingViewController = [[ScoreAnalysingViewController alloc] initWithScores:@[recentScoreListEntry.score]];
            [scoreAnalysingViewController setCompletionBlock:^(BOOL success) {
                if (success) {
                    PerformanceMode performanceMode = [recentScoreListEntry.score.preferredPerformanceMode intValue];
                    PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
                    
                    UIViewController *viewController;
                    if (performanceMode == PerformanceModePage) {
                        viewController = [[PerformancePagingViewController alloc] initWithSet:nil
                                                                                        score:recentScoreListEntry.score
                                                                                         page:nil];
                    } else {
                        viewController = [[PerformanceScrollingViewController alloc] initWithSet:nil
                                                                                           score:recentScoreListEntry.score
                                                                                            page:nil
                                                                                 performanceMode:scrollMode];
                    }
                    
                    [self.navigationController pushViewController:viewController animated:YES];
                    [[ScoreManager sharedInstance] pushScoreToRecentList:recentScoreListEntry.score];
                }
            }];
            
            MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:scoreAnalysingViewController];
            formSheet.shouldCenterVertically = YES;
            
            [self presentViewController:formSheet animated:YES completion:nil];
        }
        
    } else {
        RecentSetListEntry *recentSetListEntry = [self.setFetchedResultsController objectAtIndexPath:indexPath];
        NSArray *unAnalysedScores = [recentSetListEntry.setList unAnalyzedScores];
        
        if ([unAnalysedScores count] > 0) {
            // Start Analysing
            ScoreAnalysingViewController *scoreAnalysingViewController = [[ScoreAnalysingViewController alloc] initWithScores:unAnalysedScores];
            [scoreAnalysingViewController setCompletionBlock:^(BOOL success) {
                if (success) {
                    NSArray *setListEntries = [recentSetListEntry.setList orderedSetListEntriesAsc];
                    Score *score = [[setListEntries firstObject] score];
                    
                    PerformanceMode performanceMode = [score.preferredPerformanceMode intValue];
                    PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
                    
                    UIViewController *viewController;
                    if (performanceMode == PerformanceModePage) {
                        viewController = [[PerformancePagingViewController alloc] initWithSet:recentSetListEntry.setList
                                                                                        score:score
                                                                                         page:nil];
                    } else {
                        viewController = [[PerformanceScrollingViewController alloc] initWithSet:recentSetListEntry.setList
                                                                                           score:score
                                                                                            page:nil
                                                                                 performanceMode:scrollMode];
                    }
                    
                    [self.navigationController pushViewController:viewController animated:YES];
                    [[ScoreManager sharedInstance] pushScoreToRecentList:score];
                    [[ScoreManager sharedInstance] pushSetToRecentList:recentSetListEntry.setList];
                }
            }];
            
            MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:scoreAnalysingViewController];
            formSheet.shouldCenterVertically = YES;
            
            [self presentViewController:formSheet animated:YES completion:nil];
        } else {
            NSArray *setListEntries = [recentSetListEntry.setList orderedSetListEntriesAsc];
            Score *score = [[setListEntries firstObject] score];
            
            PerformanceMode performanceMode = [score.preferredPerformanceMode intValue];
            PerformanceMode scrollMode = (PerformanceModePage != performanceMode) ? performanceMode : PerformanceModeSimpleScroll;
            
            UIViewController *viewController;
            if (performanceMode == PerformanceModePage) {
                viewController = [[PerformancePagingViewController alloc] initWithSet:recentSetListEntry.setList
                                                                                score:score
                                                                                 page:nil];
            } else {
                viewController = [[PerformanceScrollingViewController alloc] initWithSet:recentSetListEntry.setList
                                                                                   score:score
                                                                                    page:nil
                                                                         performanceMode:scrollMode];
            }
            
            [self.navigationController pushViewController:viewController animated:YES];
            [[ScoreManager sharedInstance] pushScoreToRecentList:score];
            [[ScoreManager sharedInstance] pushSetToRecentList:recentSetListEntry.setList];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([controller isEqual:self.scoreFetchedResultsController]) {
        [self.scoreCollectionView reloadData];
    } else {
        [self.setCollectionView reloadData];
    }
}

#pragma mark - Notifications

- (void)languageChanged
{
    self.libraryButton.title = MyLocalizedString(@"centralViewLibraryButton", nil);
    self.tutorialsButton.title = MyLocalizedString(@"centralViewTutorialsButton", nil);
    self.settingsButton.title = MyLocalizedString(@"centralViewSettingsbutton", nil);

    self.scoresLabel.text = MyLocalizedString(@"centralViewLeftLabelScores", nil);
    self.setsLabel.text = MyLocalizedString(@"centralViewLeftLabelSets", nil);
}

- (void)didFinischCopyingDefaultData
{
    if (self.isViewLoaded) {
        [self hideActivityIndicator];
    }
}

- (void)scoreDidRotate:(NSNotification *)theNotification
{
    [self.scoreCollectionView reloadData];
}

#pragma mark - Activity Indicator

- (void)showActivityIndicator
{
    self.blockingView = [UIView newAutoLayoutView];
    self.blockingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.blockingView addSubview:activityIndicator];
    [self.view addSubview:self.blockingView];
    
    [self.blockingView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [activityIndicator autoCenterInSuperview];
    [activityIndicator startAnimating];
}

- (void)hideActivityIndicator
{
    [self.blockingView removeFromSuperview];
    self.blockingView = nil;
}

#pragma mark - Button Actions

- (IBAction)showLibrary
{
    NewLibraryViewController *lvc = [[NewLibraryViewController alloc] initWithNibName:@"NewLibraryViewController" bundle:nil];
    [self.navigationController pushViewController:lvc animated:YES];
    [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:kCentralViewIdentifier
                                                            actionString:kTrackingEventButton
                                                             labelString:kLibraryViewIdentifier
                                                             valueNumber:[NSNumber numberWithInt:0]];
}

- (IBAction)showTutorials
{
	TutorialViewController *tutorialViewController = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
	tutorialViewController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tutorialViewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
	[self presentViewController:navigationController animated:YES completion:nil];
   
    [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:kCentralViewIdentifier actionString:kTrackingEventButton labelString:kTutorialsViewIdentifier valueNumber:[NSNumber numberWithInt:0]];
}
 
- (IBAction)showSettings
{
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
	[self presentViewController:navigationController animated:YES completion:nil];

    [[TrackingManager sharedInstance] trackGoogleEventWithCategoryString:kCentralViewIdentifier
                                                            actionString:kTrackingEventButton
                                                             labelString:kSettingsViewIdentifier
                                                             valueNumber:@0];
}

#pragma mark - Movie Playback

- (void)playMovieWithUrl:(NSURL *)url
{
    if (nil != url) {
        BrowserViewController *browser = [[BrowserViewController alloc] initWithURL:url dismissBlock:^{
            [self performSelector:@selector(showTutorials) withObject:nil afterDelay:1.0];
        }];
        [self presentViewController:browser animated:YES completion:NULL];
    }
}

@end
