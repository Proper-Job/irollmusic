//
//  DropboxFileTransferListInboundCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DropboxFileTransferListInboundCell.h"

@implementation DropboxFileTransferListInboundCell

@synthesize label, progressView, doneLabel;


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.label.textColor = [UIColor blackColor];
    self.doneLabel.textColor = [UIColor blackColor];
    self.progressView.progressTintColor = [Helpers petrol];
    
    UIView *bg = [[UIView alloc] initWithFrame:self.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bg.backgroundColor = [Helpers petrol];
    self.selectedBackgroundView = bg;
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.label.textColor = [UIColor whiteColor];
        self.doneLabel.textColor = [UIColor whiteColor];
    } else {
        self.label.textColor = [UIColor blackColor];
        self.doneLabel.textColor = [UIColor blackColor];
    }
}

@end
