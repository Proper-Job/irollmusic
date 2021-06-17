//
//  ScoreActionsTableViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import <UIKit/UIKit.h>

@protocol ScoreActionsTableViewControllerDelegate <NSObject>

- (void)checkDocumentsDirectory;
- (void)analyseAllScores;
- (void)deleteAllScores;
- (void)linkDropbox;
- (void)unlinkDropbox;

@end

@interface ScoreActionsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, weak) id<ScoreActionsTableViewControllerDelegate> delegate;

@end
