//
//  TextAnnotation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnnotationsView;

@interface TextAnnotation : NSObject <NSCoding, UITextFieldDelegate> {
    
}

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *moveButton, *hostingView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) NSString *text, *textFontName;
@property (nonatomic, strong) NSNumber *textFontSize;
@property (nonatomic, strong) NSValue *originOfHostingView, *relativeOriginOfHostingView, *originOfTextField, *relativeOriginOfTextField, *frame;
@property (nonatomic, assign) CGFloat _textFieldWidth, _textFieldHeight, _textFieldFontSize, _deleteButtonWidth, _deleteButtonHeight, _moveButtonWidth, _moveButtonHeight, _hostingViewWidth, _hostingViewHeight;
@property (nonatomic, assign) CGPoint _locationInView;
@property (nonatomic, weak) AnnotationsView *delegate;

- (id)initWithPoint:(CGPoint)newPoint frame:(CGRect)newFrame delegate:(AnnotationsView*)newDelegate;

- (void)setTextAnnotationSize;
- (void)createTextAnnotationWithOrigin:(CGPoint)newOrigin;
- (CGPoint)adjustPointToFrameBounds:(CGPoint)pointToCheck;
- (void)createRelativeOriginOfTextField;
- (void)createRelativeOriginOfHostingView;

- (void)setupWithArgumentsDictionary:(NSDictionary*)argumentsDictionary;
- (void)resetWithFrame:(NSValue*)newFrameValue;
- (NSNumber*)relativeFontSizeForSize:(CGSize)newSize;

- (void)moveTextFieldAnnotation:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)remove;
- (void)stopEditing;

#define kTextFieldWidthPortrait 120.0
#define kTextFieldWidthLandscape 60.0
#define kTextFieldHeightPortrait 22.0
#define kTextFieldHeightLandscape 13.0

#define kTextFieldFontSizePortrait 14.0
#define kTextFieldFontSizeLandscape 10.0

#define kDeleteButtonWidthPortrait 29.0
#define kDeleteButtonWidthLandscape 15.0
#define kDeleteButtonHeightPortrait 28.0
#define kDeleteButtonHeightLandscape 15.0

#define kMoveButtonWidthPortrait 30.0
#define kMoveButtonWidthLandscape 15.0
#define kMoveButtonHeightPortrait 30.0
#define kMoveButtonHeightLandscape 15.0

#define kHostingViewWidthPortrait 180.0
#define kHostingViewWidthLandscape 90.0
#define kHostingViewHeightPortrait 56.0
#define kHostingViewHeightLandscape 28.0

//keys for arguments dictionary
#define kTextAnnotationSetupArgumentFrame @"frame"
#define kTextAnnotationSetupArgumentDelegate @"delegate"
#define kTextAnnotationSetupArgumentInvertY @"invertY"

@end

@protocol TextAnnotationDelegate <NSObject>

- (void)removeTextAnnotation:(TextAnnotation*)textAnnotation;
- (void)startedEditing:(TextAnnotation*)textAnnotation;

@end
