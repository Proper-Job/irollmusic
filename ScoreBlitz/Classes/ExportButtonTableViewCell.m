//
//  ExportButtonTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import "ExportButtonTableViewCell.h"
#import "ExportItem.h"

@implementation ExportButtonTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.button.backgroundColor = [Helpers petrol];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithExportItem:(ExportItem*)exportItem
{
    [self.button setTitle:exportItem.title forState:UIControlStateNormal];
}

@end
