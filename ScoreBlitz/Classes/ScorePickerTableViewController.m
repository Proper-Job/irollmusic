//
//  ScorePickerTableViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 01.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScorePickerTableViewController.h"
#import "Set.h"
#import "SetListEntry.h"
#import "Score.h"
#import "ScorePickerTableViewCell.h"
#import "ScoreAnalysingViewController.h"
#import "MZFormSheetPresentationController.h"


@implementation ScorePickerTableViewController

- (id)initWithSet:(Set *)setList
 activeScoreIndex:(NSInteger)activeScoreIndex
       completion:(void(^)(NSInteger scoreIndex))completion
{
    self = [super initWithNibName:@"ScorePickerTableViewController" bundle:nil];
    if (self) {
        self.setList = setList;
        self.completion = completion;
        self.activeScoreIndex = activeScoreIndex;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.setList.name;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ScorePickerTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"ScorePickerTableViewCell"];
    
    [self.tableView addObserver:self
                     forKeyPath:NSStringFromSelector(@selector(contentSize))
                        options:NSKeyValueObservingOptionNew
                        context:nil];
}

- (void)dealloc
{
    @try {
        [self.tableView removeObserver:self
                            forKeyPath:NSStringFromSelector(@selector(contentSize))];
    }
    @catch (NSException *exception) {
        ;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        self.preferredContentSize = self.tableView.contentSize;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.setList.setListEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScorePickerTableViewCell";
    
    ScorePickerTableViewCell *cell = (ScorePickerTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                                                  forIndexPath:indexPath];

    NSArray *orderedSetListEntries = [self.setList orderedSetListEntriesAsc];
    SetListEntry *listEntry = orderedSetListEntries[indexPath.row];
    cell.label.text = listEntry.score.name;
    
    if (indexPath.row == self.activeScoreIndex) {
        cell.imageView.image = [UIImage imageNamed:@"check"];
    }else {
        cell.imageView.image = nil;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ScorePickerTableViewCell *touchedCell = (ScorePickerTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    for (ScorePickerTableViewCell *aCell in [tableView visibleCells]) {
        if ([aCell isEqual:touchedCell]) {
            aCell.imageView.image = [UIImage imageNamed:@"check"];
        }else {
            aCell.imageView.image = nil;
        }
    }

    Score *newScore = [[self.setList orderedSetListEntriesAsc][indexPath.row] score];
    if (![[newScore isAnalyzed] boolValue]) {
        ScoreAnalysingViewController *controller = [[ScoreAnalysingViewController alloc] initWithScores:@[newScore]];
        controller.completionBlock = ^(BOOL success) {
            if (self.completion) {
                self.completion(indexPath.row);
            }
        };
        MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:controller];
        formSheet.shouldCenterVertically = YES;
        [self presentViewController:formSheet animated:YES completion:nil];
    }else {
        self.completion(indexPath.row);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

@end
