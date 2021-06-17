//
//  ExportTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import "ExportTableViewCell.h"
#import "APCheckedLabel.h"
#import "ExportItem.h"

@implementation ExportTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkedLabel.checkImage = [UIImage imageNamed:@"check"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithExportItem:(ExportItem*)exportItem
{
    self.checkedLabel.title = exportItem.title;
    [self.checkedLabel setChecked:exportItem.boolValue];
}

@end
