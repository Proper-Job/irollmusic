//
//  SignAnnotationMoveViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SignAnnotation, MagnifierView;

@interface SignAnnotationMoveViewController : UIViewController

@property (nonatomic, strong) UITapGestureRecognizer *_tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *_panGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *_longPressGestureRecognizer;
@property (nonatomic, assign) CGPoint _startPoint, _contentStartPoint, _longPressTouchDownPoint;
@property (nonatomic, assign) CGRect _startRect, _contentStartRect;
@property (nonatomic, weak) SignAnnotation *delegate;
@property (nonatomic, assign) CGSize _hostingViewSize;
@property (nonatomic, strong) MagnifierView *magnifierView;

- (void)showOnView:(UIView*)newView atPoint:(CGPoint)point;

- (void)showSignAnnotationEditor:(UITapGestureRecognizer*)gestureRecognizer;
- (void)moveSignAnnotation:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)resizeSignAnnotation:(UIPanGestureRecognizer*)gestureRecognizer;
- (void)setSelected:(BOOL)selected;

@end

#define kContentOffset 10.0
#define kMaxSignHeight 120
#define kMaxSignWidth 400

