//
//  ScoreDetailTableViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.06.14.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreDetailTableViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, strong) UITextField *nameTextField, *composerTextField, *genreTextField;
@property (nonatomic, strong) UILabel *playtimeLabel;
@property (nonatomic, strong) UISwitch *automaticCalculationSwitch;
@property (nonatomic, strong) UIBarButtonItem *exportBarButtonItem;

@property (nonatomic, strong) UIViewController *exportViewController;


@end
