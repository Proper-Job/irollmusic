//
//  APCheckedLabel.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 16.05.14.
//
//

#import <UIKit/UIKit.h>

@interface APCheckedLabel : UIControl

@property (nonatomic, strong) UIImage *checkImage;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

- (id)initWithFrame:(CGRect)frame title:(NSString*)title image:(UIImage*)image;

- (BOOL)isChecked;
- (void)setChecked:(BOOL)checked;

- (void)setTitle:(NSString *)title;

@end
