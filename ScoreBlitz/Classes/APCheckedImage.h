//
//  APCheckedImage.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.05.14.
//
//

#import <UIKit/UIKit.h>

@interface APCheckedImage : UIControl

@property (nonatomic, strong) UIImage *image, *checkImage;

@property (nonatomic, assign) BOOL _checked;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image checkImage:(UIImage*)checkImage;

- (BOOL)isChecked;
- (void)setChecked:(BOOL)checked;


@end
