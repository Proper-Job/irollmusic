//
//  DropboxFileListTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import "DropboxFileListTableViewCell.h"
#import "TransferFile.h"

@implementation DropboxFileListTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.nameLabel.textColor = [UIColor blackColor];
    self.addButton.tintColor = [Helpers petrol];
    
    UIView *bg = [[UIView alloc] initWithFrame:self.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bg.backgroundColor = [Helpers petrol];
    self.selectedBackgroundView = bg;
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.nameLabel.textColor = [UIColor whiteColor];
        self.addButton.tintColor = [UIColor whiteColor];
    } else {
        self.nameLabel.textColor = [UIColor blackColor];
        self.addButton.tintColor = [Helpers petrol];
    }
}

- (void)setupWithTransferFile:(TransferFile*)transferFile
{
    self.nameLabel.text = transferFile.fileName;
}

@end
