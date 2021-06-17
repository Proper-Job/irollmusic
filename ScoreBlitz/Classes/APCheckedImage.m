//
//  APCheckedImage.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.05.14.
//
//

#import "APCheckedImage.h"

@implementation APCheckedImage

@synthesize _checked;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image checkImage:(UIImage*)checkImage
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = image;
        self.checkImage = image;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat spaceBetweeenImages = 8.0;
    
    // Draw Image
    [self.image drawAtPoint:CGPointMake(0, MAX(0, roundf((rect.size.height - self.image.size.height) / 2)))];
    
    // Draw CheckImage
    if (_checked && rect.size.width >= (self.image.size.width + spaceBetweeenImages + self.checkImage.size.width)) {
        [self.checkImage drawAtPoint:CGPointMake(self.image.size.width + spaceBetweeenImages, MAX(0, roundf((rect.size.height - self.checkImage.size.height) / 2)))];
    }
    
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, location)) {
        [self setChecked:!_checked];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark - Accessors

- (BOOL)isChecked
{
    return _checked;
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    [self sendActionsForControlEvents:UIControlEventValueChanged];    
    [self setNeedsDisplay];
}

@end
