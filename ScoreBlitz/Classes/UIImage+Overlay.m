//
//  UIImage+Overlay.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 09/01/15.
//
//

#import "UIImage+Overlay.h"

@implementation UIImage (Overlay)

- (UIImage *)imageWithOverlayColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)]) {  // The scale property is new with iOS4.
            imageScale = self.scale;
        }
        UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(self.size);
    }
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
