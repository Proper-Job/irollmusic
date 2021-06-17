//
//  EditorTypeChooserTableViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 16.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditorTypeChooserTableViewController.h"
#import "ModePickerCell.h"

@implementation EditorTypeChooserTableViewController

- (id)initWithEditorType:(EditorViewControllerType)theType
    typePickedCompletion:(void(^)(EditorViewControllerType newMode))typePickedCompletion;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.editorType = theType;
        self.typePickedCompletion = typePickedCompletion;
        self.modes = @[
                @(EditorViewControllerTypeMeasures),
                @(EditorViewControllerTypeAnnotations)
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
    @catch (NSException *exception) {;}
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
    return self.modes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ModePickerCell";

    ModePickerCell *cell = (ModePickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                             forIndexPath:indexPath];

    EditorViewControllerType cellType = (EditorViewControllerType) [self.modes[indexPath.row] intValue];
    cell.titleLabel.text = [Helpers localizedEditorTypeStringForType:cellType];
    if (cellType == self.editorType) {
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

    if (self.typePickedCompletion) {
        self.typePickedCompletion((EditorViewControllerType) [self.modes[indexPath.row] intValue]);
    }
}


@end
