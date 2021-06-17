//
//  ScoreActionItemTableViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "PureLayout.h"
#import "ScoreActionItemTableViewCell.h"
#import "ScoreActionItem.h"


@implementation ScoreActionItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel = [UILabel newAutoLayoutView];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
        
        UIView *bg = [[UIView alloc] initWithFrame:self.bounds];
        bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        bg.backgroundColor = [Helpers petrol];
        self.selectedBackgroundView = bg;
        
        self.preservesSuperviewLayoutMargins = NO;
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        [self updateFonts];
        
    }
    
    return self;
}

- (void)updateFonts
{
    self.titleLabel.font = [Helpers avenirNextMediumFontWithSize:16.0];
}


- (void)setupWithScoreActionItem:(ScoreActionItem*)scoreActionItem
{
    self.titleLabel.text = scoreActionItem.title;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
        // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
        //      See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        //[self.contentView autoSetDimension:ALDimensionHeight toSize:44.0 relation:NSLayoutRelationGreaterThanOrEqual];
        
        // Row 1
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
        }];
        
        [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(8.0, 20.0, 8.0, 20.0)];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
