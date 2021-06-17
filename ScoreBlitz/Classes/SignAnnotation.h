//
//  SignAnnotation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 14.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnnotationsView, SignAnnotationViewController, SignAnnotationMoveViewController, SVGDocument;

@interface SignAnnotation : NSObject <NSCoding, UIPopoverControllerDelegate>


@property (nonatomic, strong) CALayer *caLayer;
@property (nonatomic, strong) SVGDocument *svgDocument;
@property (nonatomic, strong) NSString *signName;
@property (nonatomic, strong) UIImage *signImage;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSValue *hostingViewFrame, *bounds, *relativeBounds, *originalBounds, *position, *relativePosition;
@property (nonatomic, strong) SignAnnotationViewController *signAnnotationViewController;
@property (nonatomic, strong) SignAnnotationMoveViewController *signAnnotationMoveViewController;
@property (nonatomic, strong) UIPopoverController *_popoverController;

@property (nonatomic, weak) AnnotationsView *delegate;

- (id)init;
- (id)initWithPoint:(CGPoint)newPoint hostingViewFrame:(CGRect)newFrame delegate:(AnnotationsView*)annotationsViewDelegate;

- (void)show;
- (void)hide;
- (void)showSignAnnotationViewControllerOnView:(UIView*)view;
- (void)hideSignAnnotationViewController;
- (void)hideSignAnnotationViewControllerAndShowSignAnnotationMoveViewController;
- (void)showSignAnnotationMoveViewControllerOnView:(UIView*)view;
- (void)hideSignAnnotationMoveViewController;
- (BOOL)isEditing;
- (void)deleteSelf;

- (void)setupWithArgumentsDictionary:(NSDictionary*)argumentsDictionary;
- (void)resetHostingViewFrame:(NSValue*)newFrameValue;
- (CALayer*)changeLayerToSign:(NSString*)newSignName;
- (void)createRelativePosition;
- (void)createRelativeBounds;
- (void)changeLayerBoundsToRect:(CGRect)newRect;
- (void)changeLayerPositionToPoint:(CGPoint)newPoint;
- (void)changeLayerFrameToRect:(CGRect)newRect;
- (void)fitLayerIntoFrame:(CGRect)newFrame;

//keys for arguments dictionary
#define kSignAnnotationSetupArgumentFrame @"frame"
#define kSignAnnotationSetupArgumentDelegate @"delegate"
#define kSignAnnotationSetupArgumentInvertY @"invertY"

@end

@protocol SignAnnotationDelegate <NSObject>

- (void)removeSignAnnotation:(SignAnnotation*)signAnnotation;

@end

