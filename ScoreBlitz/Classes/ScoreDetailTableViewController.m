//
//  ScoreDetailTableViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import "ScoreDetailTableViewController.h"
#import "Score.h"
#import "ScoreDetailNameTableViewCell.h"
#import "ScoreDetailComposerTableViewCell.h"
#import "ScoreDetailGenreTableViewCell.h"
#import "ScoreDetailPlaytimeTableViewCell.h"
#import "ScoreDetailAutomaticCalculationTableViewCell.h"
#import "ScoreDetailPreviewTableViewCell.h"
#import "ScoreDetailRowItem.h"
#import "ScoreDetailSectionItem.h"
#import "ScoreManager.h"
#import "ExportTableViewController.h"
#import "PerformanceManager.h"
#import "EditorViewController.h"
#import "ScoreRotationViewController.h"
#import "MZFormSheetPresentationController.h"
#import "ScoreAnalysingViewController.h"
#import "HelpViewPopOverViewController.h"

@interface ScoreDetailTableViewController ()

@end

@implementation ScoreDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(libraryScoreListSelectionDidChange:)
                                                 name:kLibraryScoreListSelectionDidChange object:nil];
    
    UIBarButtonItem *composeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTapped:)];
    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.exportBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(exportTapped:)];
    [self setToolbarItems:@[composeBarButtonItem, flexibleSpaceBarButtonItem, self.exportBarButtonItem]];
    
    self.tableView.backgroundColor = [Helpers lightGrey];
    self.tableView.separatorColor = [Helpers lightGrey];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ScoreDetailNameTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScoreDetailNameTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ScoreDetailComposerTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScoreDetailComposerTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ScoreDetailGenreTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScoreDetailGenreTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ScoreDetailPlaytimeTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScoreDetailPlaytimeTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ScoreDetailAutomaticCalculationTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScoreDetailAutomaticCalculationTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ScoreDetailPreviewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScoreDetailPreviewTableViewCell"];
    
    NSMutableArray *newSections = [NSMutableArray array];
    NSMutableArray *headerRows = [NSMutableArray array];
    
    ScoreDetailRowItem *nameItem = [[ScoreDetailRowItem alloc] init];
    nameItem.scoreDetailTableViewCellType = ScoreDetailTableViewCellTypeName;
    [headerRows addObject:nameItem];

    ScoreDetailRowItem *composerItem = [[ScoreDetailRowItem alloc] init];
    composerItem.scoreDetailTableViewCellType = ScoreDetailTableViewCellTypeComposer;
    [headerRows addObject:composerItem];

    ScoreDetailRowItem *genreItem = [[ScoreDetailRowItem alloc] init];
    genreItem.scoreDetailTableViewCellType = ScoreDetailTableViewCellTypeGenre;
    [headerRows addObject:genreItem];
    
    ScoreDetailSectionItem *headerSection = [[ScoreDetailSectionItem alloc] init];
    headerSection.scoreDetailTableViewSectionType = ScoreDetailTableViewSectionTypeHeader;
    headerSection.rows = headerRows;
    [newSections addObject:headerSection];
    

    NSMutableArray *playtimeRows = [NSMutableArray array];
    
    ScoreDetailRowItem *playtimeItem = [[ScoreDetailRowItem alloc] init];
    playtimeItem.scoreDetailTableViewCellType = ScoreDetailTableViewCellTypePlaytime;
    [playtimeRows addObject:playtimeItem];
    
    ScoreDetailRowItem *automaticCalculationItem = [[ScoreDetailRowItem alloc] init];
    automaticCalculationItem.scoreDetailTableViewCellType = ScoreDetailTableViewCellTypeAutomaticCalculation;
    [playtimeRows addObject:automaticCalculationItem];
    
    ScoreDetailSectionItem *playtimeSection = [[ScoreDetailSectionItem alloc] init];
    playtimeSection.scoreDetailTableViewSectionType = ScoreDetailTableViewSectionTypeSpacer;
    playtimeSection.rows = playtimeRows;
    [newSections addObject:playtimeSection];

    
    NSMutableArray *previewRows = [NSMutableArray array];
    
    ScoreDetailRowItem *previewItem = [[ScoreDetailRowItem alloc] init];
    previewItem.scoreDetailTableViewCellType = ScoreDetailTableViewCellTypePreview;
    [previewRows addObject:previewItem];
    
    ScoreDetailSectionItem *previewSection = [[ScoreDetailSectionItem alloc] init];
    previewSection.scoreDetailTableViewSectionType = ScoreDetailTableViewSectionTypeSpacer;
    previewSection.rows = previewRows;
    [newSections addObject:previewSection];
    
    self.sections = newSections;
    self.textFields = [NSMutableArray array];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
    [[ScoreManager sharedInstance] saveTheFuckingContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];    
    [[ScoreManager sharedInstance] saveTheFuckingContext];
}

#pragma mark - Button Actions

- (IBAction)playtimeTapped:(id)sender
{
    UIButton *playtimeButton = (UIButton*)sender;
    CGRect convertedRect = [self.view convertRect:playtimeButton.frame fromView:playtimeButton.superview];

    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationPopover;
    viewController.preferredContentSize = CGSizeMake(pickerView.frame.size.width, pickerView.frame.size.height);
    
    viewController.view.frame = pickerView.frame;
    [viewController.view addSubview:pickerView];
    
    [pickerView selectRow:[self.score.playTime intValue] / 60 inComponent:0 animated:NO];
    [pickerView selectRow:[self.score.playTime intValue] % 60 inComponent:1 animated:NO];    
        
    [self presentViewController:viewController animated:YES completion:nil];
    
    UIPopoverPresentationController *presentationController = [viewController popoverPresentationController];
    presentationController.sourceRect = convertedRect;
    presentationController.sourceView = self.view;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
}

- (IBAction)automaticCalculationInfoTapped:(id)sender
{
    UIButton *infoButton = (UIButton *)sender;
    CGRect convertedRect = [self.view convertRect:infoButton.frame fromView:infoButton.superview];
    HelpViewPopOverViewController *controller = [[HelpViewPopOverViewController alloc] initWithTemplate:MyLocalizedString(@"popoverHelpTemplatePlaytimeCalc", nil)
                                                                                            controlItem:nil
                                                                                    webViewFinishedLoad:nil];
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
    controller.popoverPresentationController.sourceView = self.view;
    controller.popoverPresentationController.sourceRect = convertedRect;
    controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    controller.popoverPresentationController.passthroughViews = nil;
    [controller loadContent];
}

- (IBAction)automaticCalculationSwitchValueChanged:(id)sender
{
    if (nil != self.score) {
        self.score.automaticPlayTimeCalculation = @(![self.score.automaticPlayTimeCalculation boolValue]);
        [self.score refreshPlaytime]; // checks for auto playtime calculation
        self.playtimeLabel.text = [self.score playTimeString];
    }
}

- (IBAction)composeTapped:(id)sender
{
    if (self.exportViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.exportViewController = nil;
        }];
    }
    
    EditorViewController *editor = [[EditorViewController alloc] initWithScore:self.score
                                                                          page:nil
                                                      editorViewControllerType:EditorViewControllerTypeAnnotations
                                                                  dismissBlock:nil];
    if ([self.score.isAnalyzed boolValue]) {
        [self.splitViewController.navigationController pushViewController:editor animated:YES];
    } else {
        ScoreAnalysingViewController *controller = [[ScoreAnalysingViewController alloc] initWithScores:@[self.score]];
        controller.completionBlock = ^(BOOL success)
        {
            [self.splitViewController.navigationController pushViewController:editor animated:YES];
        };
        MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:controller];
        formSheet.shouldCenterVertically = YES;
        [self presentViewController:formSheet animated:YES completion:nil];
    }
}

- (IBAction)exportTapped:(id)sender
{
    if (self.score != nil) {
        UIBarButtonItem *barButtonItem= (UIBarButtonItem*)sender;
        ExportTableViewController *exportTableViewController = [[ExportTableViewController alloc] initWithScore:self.score];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:exportTableViewController];
        self.exportViewController = navigationController;
        
        navigationController.modalPresentationStyle = UIModalPresentationPopover;
        
        [self presentViewController:navigationController animated:YES completion:nil];
        
        UIPopoverPresentationController *presentationController = [navigationController popoverPresentationController];
        presentationController.barButtonItem = barButtonItem;
        presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
}

- (IBAction)rotateScoreTapped:(id)sender
{
    ScoreRotationViewController *scoreRotationViewController = [[ScoreRotationViewController alloc] initWithScore:self.score];
    MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:scoreRotationViewController];
    formSheet.shouldCenterVertically = YES;
    
    [self presentViewController:formSheet animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.sections objectAtIndex:section] rows] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreDetailRowItem *scoreDetailRowItem = [[[self.sections objectAtIndex:indexPath.section] rows] objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    
    switch (scoreDetailRowItem.scoreDetailTableViewCellType) {
        case ScoreDetailTableViewCellTypeName: {
            ScoreDetailNameTableViewCell *scoreDetailNameTableViewCell = (ScoreDetailNameTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreDetailNameTableViewCell" forIndexPath:indexPath];
            [scoreDetailNameTableViewCell setupWithScore:self.score];
            scoreDetailNameTableViewCell.nameTextField.delegate = self;
            self.nameTextField = scoreDetailNameTableViewCell.nameTextField;
            [self.textFields addObject:scoreDetailNameTableViewCell.nameTextField];
            cell = scoreDetailNameTableViewCell;
            break;
        }
            
        case ScoreDetailTableViewCellTypeComposer: {
            ScoreDetailComposerTableViewCell *scoreDetailComposerTableViewCell = (ScoreDetailComposerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreDetailComposerTableViewCell" forIndexPath:indexPath];
            [scoreDetailComposerTableViewCell setupWithScore:self.score];
            scoreDetailComposerTableViewCell.composerTextField.delegate = self;
            self.composerTextField = scoreDetailComposerTableViewCell.composerTextField;
            [self.textFields addObject:scoreDetailComposerTableViewCell.composerTextField];
            cell = scoreDetailComposerTableViewCell;
            break;
        }

        case ScoreDetailTableViewCellTypeGenre: {
            ScoreDetailGenreTableViewCell *scoreDetailGenreTableViewCell = (ScoreDetailGenreTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreDetailGenreTableViewCell" forIndexPath:indexPath];
            [scoreDetailGenreTableViewCell setupWithScore:self.score];
            scoreDetailGenreTableViewCell.genreTextField.delegate = self;
            self.genreTextField = scoreDetailGenreTableViewCell.genreTextField;
            [self.textFields addObject:scoreDetailGenreTableViewCell.genreTextField];
            cell = scoreDetailGenreTableViewCell;
            break;
        }
            
        case ScoreDetailTableViewCellTypePlaytime: {
            ScoreDetailPlaytimeTableViewCell *scoreDetailPlaytimeTableViewCell = (ScoreDetailPlaytimeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreDetailPlaytimeTableViewCell" forIndexPath:indexPath];
            [scoreDetailPlaytimeTableViewCell setupWithScore:self.score];
            [scoreDetailPlaytimeTableViewCell.playtimeButton addTarget:self action:@selector(playtimeTapped:) forControlEvents:UIControlEventTouchUpInside];
            self.playtimeLabel = scoreDetailPlaytimeTableViewCell.timeLabel;
            cell = scoreDetailPlaytimeTableViewCell;
            break;
        }

        case ScoreDetailTableViewCellTypeAutomaticCalculation: {
            ScoreDetailAutomaticCalculationTableViewCell *scoreDetailAutomaticCalculationTableViewCell = (ScoreDetailAutomaticCalculationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreDetailAutomaticCalculationTableViewCell" forIndexPath:indexPath];
            [scoreDetailAutomaticCalculationTableViewCell setupWithScore:self.score];
            [scoreDetailAutomaticCalculationTableViewCell.infoButton addTarget:self action:@selector(automaticCalculationInfoTapped:) forControlEvents:UIControlEventTouchUpInside];
            [scoreDetailAutomaticCalculationTableViewCell.automaticCalculationSwitch addTarget:self action:@selector(automaticCalculationSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            self.automaticCalculationSwitch = scoreDetailAutomaticCalculationTableViewCell.automaticCalculationSwitch;
            cell = scoreDetailAutomaticCalculationTableViewCell;
            break;
        }
            
        default: { // ScoreDetailTableViewCellTypePreview
            ScoreDetailPreviewTableViewCell *scoreDetailPreviewTableViewCell = (ScoreDetailPreviewTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreDetailPreviewTableViewCell" forIndexPath:indexPath];
            [scoreDetailPreviewTableViewCell setupWithScore:self.score];
            [scoreDetailPreviewTableViewCell.rotationButton addTarget:self action:@selector(rotateScoreTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell = scoreDetailPreviewTableViewCell;

            break;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreDetailRowItem *scoreDetailRowItem = [[[self.sections objectAtIndex:indexPath.section] rows] objectAtIndex:indexPath.row];
    
    switch (scoreDetailRowItem.scoreDetailTableViewCellType) {
        case ScoreDetailTableViewCellTypePreview: {
            return 336.0;
            break;
        }
            
        default: {
            return 45.0;
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    ScoreDetailSectionItem *scoreDetailSectionItem = [self.sections objectAtIndex:section];
    
    switch (scoreDetailSectionItem.scoreDetailTableViewSectionType) {
        case ScoreDetailTableViewSectionTypeHeader: {
            return 44.0;
            break;
        }
            
        default: { //ScoreDetailTableViewSectionTypeSpacer
            return 20.0;
            break;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ScoreDetailSectionItem *scoreDetailSectionItem = [self.sections objectAtIndex:section];
    
    switch (scoreDetailSectionItem.scoreDetailTableViewSectionType) {
        case ScoreDetailTableViewSectionTypeHeader: {
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
            headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            headerLabel.textAlignment = NSTextAlignmentCenter;
            headerLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:24.0];
            headerLabel.text = @"DETAILS";
            return headerLabel;
            break;
        }
            
        default: { //ScoreDetailTableViewSectionTypeSpacer
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20.0)];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            view.backgroundColor = [UIColor clearColor];
            return view;
            break;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField]) {
        self.score.name = self.nameTextField.text;
    } else if ([textField isEqual:self.composerTextField]) {
        self.score.composer = self.composerTextField.text;
    } else if ([textField isEqual:self.genreTextField]) {
        self.score.genre = self.genreTextField.text;
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 60;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.score.playTime = @(row * 60 + [self.score.playTime intValue] % 60);
    } else {
        self.score.playTime = @(row + ([self.score.playTime intValue] - [self.score.playTime intValue] % 60));
    }
    //[[ScoreManager sharedInstance] saveTheFuckingContext];
    self.playtimeLabel.text = [self.score playTimeString];
    
    if ([self.score.automaticPlayTimeCalculation boolValue]) {
        [self.automaticCalculationSwitch setOn:NO animated:YES];
        [self automaticCalculationSwitchValueChanged:nil];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", row];
}


#pragma mark - Notifications

- (void)libraryScoreListSelectionDidChange:(NSNotification*)notification
{
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
    [[ScoreManager sharedInstance] saveTheFuckingContext];
    
    if ([notification userInfo] == nil) {
        self.score = nil;
    } else {
        self.score = [notification userInfo][kLibraryScoreListSelectionDidChangeObjectKey];
    }
    [self.tableView reloadData];
}

@end
