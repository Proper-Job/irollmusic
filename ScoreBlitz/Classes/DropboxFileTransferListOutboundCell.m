//
//  DropboxFileTransferListOutboundCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DropboxFileTransferListOutboundCell.h"

@implementation DropboxFileTransferListOutboundCell

@synthesize label, progressView, fileSelector, annotationsSelector, doneLabel;


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.label.textColor = [UIColor blackColor];
    self.doneLabel.textColor = [UIColor blackColor];
    self.fileSelector.tintColor = [Helpers petrol];
    self.annotationsSelector.tintColor = [Helpers petrol];
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
        self.fileSelector.tintColor = [UIColor whiteColor];
        self.annotationsSelector.tintColor = [UIColor whiteColor];
    } else {
        self.label.textColor = [UIColor blackColor];
        self.doneLabel.textColor = [UIColor blackColor];
        self.fileSelector.tintColor = [Helpers petrol];
        self.annotationsSelector.tintColor = [Helpers petrol];
    }
}

- (IBAction)fileSelectorSwitched
{
    // send notification to change property in transferFile object
    [[NSNotificationCenter defaultCenter] postNotificationName:kFileSelectorInOutBoundCellToggled object:self];
}

- (IBAction)annotationsSelectorSwitched
{
    // send notification to change property in transferFile object
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnnotationsSelectorInOutBoundCellToggled object:self];
}

@end
