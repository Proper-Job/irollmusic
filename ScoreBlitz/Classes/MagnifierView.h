//
//  MagnifierView.h
//

#import <UIKit/UIKit.h>

@interface MagnifierView : UIView {
	UIView *viewToMagnify;
	CGPoint touchPoint;
}

@property (nonatomic, strong) UIView *viewToMagnify;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGFloat scaleFactor, offsetToTouch;

#define kMagnifierHeight 80
#define kMagnifierWidth 80

@end
