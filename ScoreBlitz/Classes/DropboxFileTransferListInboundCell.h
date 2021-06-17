//
//  DropboxFileTransferListInboundCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropboxFileTransferListInboundCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *label, *doneLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;


@end
