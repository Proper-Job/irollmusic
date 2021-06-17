//
// Created by Moritz Pfeiffer on 31/07/15.
//

#import <Foundation/Foundation.h>

@interface UIViewController (Orientation)

typedef enum {
    ViewOrientationPortrait,
    ViewOrientationLandscape,
} ViewOrientation;

- (ViewOrientation)viewOrientation;
- (ViewOrientation)viewOrientationForSize:(CGSize)size;

@end