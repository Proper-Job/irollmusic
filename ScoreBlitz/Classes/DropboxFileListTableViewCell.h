//
//  DropboxFileListTableViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 19.12.14.
//
//

#import <UIKit/UIKit.h>

@class TransferFile;

@interface DropboxFileListTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIButton *addButton;

- (void)setupWithTransferFile:(TransferFile*)transferFile;

@end
