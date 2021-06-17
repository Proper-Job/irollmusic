//
// Created by Moritz Pfeiffer on 31/07/15.
//

#import "UIViewController+Orientation.h"


@implementation UIViewController (Orientation)

- (ViewOrientation)viewOrientation {
    if (self.view.bounds.size.height > self.view.bounds.size.width) {
        return ViewOrientationPortrait;
    }else {
        return ViewOrientationLandscape;
    }
}

- (ViewOrientation)viewOrientationForSize:(CGSize)size {
    if (size.height > size.width) {
        return ViewOrientationPortrait;
    }else {
        return ViewOrientationLandscape;
    }
}

@end