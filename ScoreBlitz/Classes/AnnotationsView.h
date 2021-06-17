//
//  AnnotationsView.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 13.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationsStylePopoverViewController.h"
#import "TextAnnotation.h"
#import "SignAnnotation.h"
#import "MultipleSignAnnotationViewController.h"

@class DrawAnnotation, Page, AnnotationPen;
@class HelpAwareSegmentedControl;

typedef enum {
    AnnotationInputModeDraw,
    AnnotationInputModeType,
    AnnotationInputModeErase,
    AnnotationInputModeSign,
    AnnotationInputModeZoom
} AnnotationInputMode;

@interface AnnotationsView : UIView <UITextFieldDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, 
AnnotationsStylePopoverViewControllerDelegate, TextAnnotationDelegate, UIGestureRecognizerDelegate,
        SignAnnotationDelegate, MultipleSignAnnotationViewControllerDelegate>
{
    AnnotationInputMode _annotationInputMode;
}

@property (nonatomic, strong) UIBarButtonItem *annotationsPenButton, *annotationsClearButton, *annotationsSegmentButton;
@property (nonatomic, strong) HelpAwareSegmentedControl *inputControlSegment;
@property (nonatomic, strong) DrawAnnotation *drawAnnotation;
@property (nonatomic, strong) NSMutableArray *drawAnnotations, *textAnnotations, *signAnnotations;
@property (nonatomic, strong) AnnotationPen *drawPen, *erasePen, *currentPen;
@property (nonatomic, strong) UIPanGestureRecognizer *multiSignSelectRecognizer, *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) NSMutableSet *multiSignSelection;
@property (nonatomic, strong) Page *activePage;
@property (nonatomic, strong) MultipleSignAnnotationViewController *multipleSignAnnotationViewController;
@property (nonatomic, strong) UIPopoverController  *penPopoverController, *multiSignAnnotationPopoverController;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL drawMode;
@property (nonatomic, assign) CGPoint locationInView;

- (id)initWithFrame:(CGRect)frame page:(Page *)page delegate:(id)theDelegate;
- (void)configureForFrame:(CGRect)frame;
- (void)willDissmissAnnotationsView;

- (void)segmentedControlTapped;
- (void)penTapped;
- (void)clearTapped;
- (void)previousTapped;
- (void)nextTapped;
- (void)showPage:(Page *)thePage;


- (void)drawPoint:(CGPoint)point;
- (void)endDrawing:(CGPoint)point;
- (void)addTextAnnotationAtPoint:(CGPoint)point;
- (BOOL)endEditingOfTextAnnotation;
- (void)addSignAnnotationAtPoint:(CGPoint)point;
- (BOOL)endEditingOfSignAnnotation;
- (void)removeSignAnnotationInterfaces;

- (void)draw:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)tap:(UITapGestureRecognizer*)tapGestureRecognizer;

- (void)activePageDidChange:(Page *)page;
- (void)clearPage;
- (void)saveAnnotations;
- (void)restoreAnnotations;


- (void)penDidChange:(AnnotationPen *)newPen;

- (void)removeTextAnnotation:(TextAnnotation*)textAnnotation;


- (void)startedEditing:(TextAnnotation*)textAnnotation;



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

#define kAnnotationTypeChooserSegmentWidth 45.0
@end

@protocol AnnotationsViewDelegate <NSObject>
- (IBAction)previousPage;
- (IBAction)nextPage;
@end
