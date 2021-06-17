//
//  ExportTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import <UIKit/UIKit.h>

@class APCheckedLabel, ExportItem;

@interface ExportTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet APCheckedLabel *checkedLabel;

- (void)setupWithExportItem:(ExportItem*)exportItem;

@end
