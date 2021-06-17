//
//  ScoreActionsTableViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "ScoreActionsTableViewController.h"
#import "ScoreBlitzAppDelegate.h"
#import "ScoreActionItem.h"
#import "ScoreActionItemTableViewCell.h"
#import "ScoreActionSectionItem.h"

@interface ScoreActionsTableViewController ()

@end

@implementation ScoreActionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = MyLocalizedString(@"ScoreActionTableViewControllerTitle", nil);
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView registerClass:[ScoreActionItemTableViewCell class] forCellReuseIdentifier:@"ScoreActionItemTableViewCell"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.sections = [self createScoreActionItems];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)createScoreActionItems
{
    NSMutableArray *sections = [NSMutableArray array];

    ScoreActionSectionItem *importSectionItem = [[ScoreActionSectionItem alloc] init];
    importSectionItem.title = MyLocalizedString(@"ScoreActionSectionTitleImport", nil);
    importSectionItem.scoreActionItems = [NSMutableArray array];
    
    ScoreActionItem *checkDocumentsDirectoyItem = [[ScoreActionItem alloc] init];
    checkDocumentsDirectoyItem.title = MyLocalizedString(@"CheckDocumentsDirectoryItemTitle", nil);
    checkDocumentsDirectoyItem.scoreActionType = ScoreActionTypeCheckDocumentsDirectory;
    
    [importSectionItem.scoreActionItems addObject:checkDocumentsDirectoyItem];
    [sections addObject:importSectionItem];

    ScoreActionSectionItem *scoreSectionItem = [[ScoreActionSectionItem alloc] init];
    scoreSectionItem.title = MyLocalizedString(@"ScoreActionSectionTitleScores", nil);
    scoreSectionItem.scoreActionItems = [NSMutableArray array];
    
    ScoreActionItem *analyseAllScoresItem = [[ScoreActionItem alloc] init];
    analyseAllScoresItem.title = MyLocalizedString(@"buttonAnalyzeAllScores", nil);
    analyseAllScoresItem.scoreActionType = ScoreActionTypeAnalyseAllScores;
    [scoreSectionItem.scoreActionItems addObject:analyseAllScoresItem];
    
    ScoreActionItem *deleteAllScoresItem = [[ScoreActionItem alloc] init];
    deleteAllScoresItem.title = MyLocalizedString(@"DeleteAllScoresItemTitle", nil);
    deleteAllScoresItem.scoreActionType = ScoreActionTypeDeleteAllScores;
    
    [scoreSectionItem.scoreActionItems addObject:deleteAllScoresItem];
    [sections addObject:scoreSectionItem];

    ScoreActionSectionItem *dropboxSectionItem = [[ScoreActionSectionItem alloc] init];
    dropboxSectionItem.title = MyLocalizedString(@"ScoreActionSectionTitleDropbox", nil);
    dropboxSectionItem.scoreActionItems = [NSMutableArray array];
    
    ScoreActionItem *linkDropboxItem = [[ScoreActionItem alloc] init];
    linkDropboxItem.title = MyLocalizedString(@"LinkDropboxItemTitle", nil);
    linkDropboxItem.scoreActionType = ScoreActionTypeLinkDropbox;
    [dropboxSectionItem.scoreActionItems addObject:linkDropboxItem];

    ScoreActionItem *unlinkDropboxItem = [[ScoreActionItem alloc] init];
    unlinkDropboxItem.title = MyLocalizedString(@"UnlinkDropboxItemTitle", nil);
    unlinkDropboxItem.scoreActionType = ScoreActionTypeUnlinkDropbox;
    
    [dropboxSectionItem.scoreActionItems addObject:unlinkDropboxItem];
    [sections addObject:dropboxSectionItem];
    
    return sections;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.sections objectAtIndex:section] scoreActionItems] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScoreActionItem *scoreActionItem = [[[self.sections objectAtIndex:indexPath.section] scoreActionItems] objectAtIndex:indexPath.row];
    
    ScoreActionItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreActionItemTableViewCell" forIndexPath:indexPath];
    [cell updateFonts];
    [cell setupWithScoreActionItem:scoreActionItem];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ScoreActionItem *scoreActionItem = [[[self.sections objectAtIndex:indexPath.section] scoreActionItems] objectAtIndex:indexPath.row];
    
    switch (scoreActionItem.scoreActionType) {
        case ScoreActionTypeAnalyseAllScores: {
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(analyseAllScores)]) {
                    [self.delegate analyseAllScores];
                }
            }];
            break;
        }

        case ScoreActionTypeDeleteAllScores: {
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(deleteAllScores)]) {
                    [self.delegate deleteAllScores];
                }
            }];
            break;
        }

        case ScoreActionTypeLinkDropbox: {
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(linkDropbox)]) {
                    [self.delegate linkDropbox];
                }
            }];
            break;
        }

        case ScoreActionTypeUnlinkDropbox: {
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(unlinkDropbox)]) {
                    [self.delegate unlinkDropbox];
                }
            }];
            break;
        }
            
        default: { // ScoreActionTypeCheckDocumentsDirectory
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(checkDocumentsDirectory)]) {
                    [self.delegate checkDocumentsDirectory];
                }
            }];
            break;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ScoreActionSectionItem *scoreActionSectionItem = [self.sections objectAtIndex:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0, self.view.bounds.size.width - 40.0, 44.0)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.font = [Helpers avenirNextMediumFontWithSize:18.0];
    titleLabel.text = scoreActionSectionItem.title;
    [headerView addSubview:titleLabel];
    
    return headerView;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

@end
