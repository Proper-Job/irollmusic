//
//  PerformanceModePickerTableViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerformanceModePickerTableViewController.h"
#import "ModePickerCell.h"

@implementation PerformanceModePickerTableViewController

- (id)initWithPerformanceMode:(PerformanceMode)theMode
         modePickedCompletion:(void(^)(PerformanceMode newMode))modePickedCompletion
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.modePickedCompletion = modePickedCompletion;
        self.performanceMode = theMode;
        self.performanceModes = @[
                @(PerformanceModeSimpleScroll),
                @(PerformanceModeAdvancedScroll),
                @(PerformanceModePage)
        ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = MyLocalizedString(@"choosePerformanceModePopoverTitle", nil);

    [self.tableView registerNib:[UINib nibWithNibName:@"ModePickerCell" bundle:nil]
         forCellReuseIdentifier:@"ModePickerCell"];
    
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
    return [self.performanceModes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ModePickerCell";
    
    ModePickerCell *cell = (ModePickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                             forIndexPath:indexPath];
    
    PerformanceMode cellMode = (PerformanceMode) [self.performanceModes[indexPath.row] intValue];
    cell.titleLabel.text = [Helpers localizedPerformanceModeStringForMode:cellMode];
    if (cellMode == self.performanceMode) {
        cell.checkmarkImageView.image = [UIImage imageNamed:@"check"];
    }else {
        cell.checkmarkImageView.image = nil;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ModePickerCell *touchedCell = (ModePickerCell *) [tableView cellForRowAtIndexPath:indexPath];
    for (ModePickerCell *aCell in [tableView visibleCells]) {
        if ([aCell isEqual:touchedCell]) {
            aCell.checkmarkImageView.image = [UIImage imageNamed:@"check"];
        }else {
            aCell.checkmarkImageView.image = nil;
        }
    }
    
    if (self.modePickedCompletion) {
        self.modePickedCompletion((PerformanceMode) [self.performanceModes[indexPath.row] intValue]);
    }
}

@end
