//
//  APCheckedLabel.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 16.05.14.
//
//

#import "APCheckedLabel.h"

@implementation APCheckedLabel {
@private
    BOOL _checked;
    NSString *_title;
    
}

- (id)initWithFrame:(CGRect)frame title:(NSString*)title image:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        _title = title;
        self.checkImage = image;
        self.font = [UIFont systemFontOfSize:17.0];
        self.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.font = [UIFont systemFontOfSize:17.0];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    // Draw Text
    NSDictionary *textAttributes = @{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor};
    CGSize textSize = [_title sizeWithAttributes:textAttributes];
    
    CGPoint textOrigin = CGPointZero;
    if (rect.size.height > textSize.height) {
        textOrigin.y = roundf((rect.size.height - textSize.height) /2);
    }
    
    CGRect textRect = CGRectMake(textOrigin.x, textOrigin.y, MAX(0, (rect.size.width - self.checkImage.size.width)), rect.size.height);
    [_title drawInRect:textRect withAttributes:textAttributes];

    
    // Draw CheckImage
    if (_checked && rect.size.width >= self.checkImage.size.width) {
        CGPoint imageOrigin = CGPointZero;
        imageOrigin.x = roundf(rect.size.width - self.checkImage.size.width);
        if (rect.size.height > self.checkImage.size.height ) {
            imageOrigin.y = roundf((rect.size.height - self.checkImage.size.height) / 2);
        }
        [self.checkImage drawAtPoint:imageOrigin];
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

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setNeedsDisplay];    
}

@end
