//
//  ExportButtonTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import <UIKit/UIKit.h>

@class ExportItem;

@interface ExportButtonTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *button;

- (void)setupWithExportItem:(ExportItem*)exportItem;

@end
