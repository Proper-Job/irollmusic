//
//  ScoreDetailPreviewTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import "ScoreDetailPreviewTableViewCell.h"
#import "Score.h"
#import "Page.h"
#import "Helpers.h"

@implementation ScoreDetailPreviewTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [Helpers lightGrey];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithScore:(Score*)score
{
    NSArray *orderedPages = [score orderedPagesAsc];
    if (orderedPages && [orderedPages count] > 0) {
        UIImage *previewImage = [[[score orderedPagesAsc] objectAtIndex:0] previewImage];
        self.previewImageView.image = previewImage;
    } else {
        self.previewImageView.image = nil;
    }
}

@end
