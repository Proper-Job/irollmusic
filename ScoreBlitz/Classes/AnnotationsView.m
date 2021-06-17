//
//  AnnotationsView.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 13.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnotationsView.h"
#import "DrawAnnotation.h"
#import "AnnotationPen.h"
#import "Score.h"
#import "Page.h"
#import "ScoreManager.h"
#import "HelpAwareSegmentedControl.h"
#import "EditorViewController.h"
#import "EditorScrollView.h"
#import "SignAnnotationMoveViewController.h"

@interface AnnotationsView ()
- (void)selectSignsWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
@end

@implementation AnnotationsView

- (id)initWithFrame:(CGRect)frame page:(Page *)page delegate:(id)theDelegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.activePage = page;
        self.delegate = theDelegate;
        
        [self restoreAnnotations];
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        NSArray *segItems = @[
                [UIImage imageNamed:@"pencil"],
                [UIImage imageNamed:@"note"],
                [UIImage imageNamed:@"eraser"],
                [UIImage imageNamed:@"forte_icon"],
                [UIImage imageNamed:@"editor_zoom"]
        ];
        
        self.inputControlSegment = [[HelpAwareSegmentedControl alloc] initWithItems:segItems];
        self.inputControlSegment.tintColor = [Helpers petrol];
        [self.inputControlSegment addTarget:self
                                 action:@selector(segmentedControlTapped)
                       forControlEvents:UIControlEventValueChanged];
        self.inputControlSegment.selectedSegmentIndex = 0;
        
        for (int i = 0; i < [segItems count]; i++) {
            [self.inputControlSegment setWidth:kAnnotationTypeChooserSegmentWidth
                        forSegmentAtIndex:i];
        }
        
        self.annotationsSegmentButton = [[UIBarButtonItem alloc] initWithCustomView:self.inputControlSegment];

        
        self.annotationsClearButton = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"clearAnnotationsButton", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(clearTapped)];
        self.annotationsPenButton = [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"penAnnotationsButton", nil)
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self
                                                                  action:@selector(penTapped)]; 
        self.annotationsPenButton.possibleTitles = [Helpers penBarButtonPossibleTitles];
        
        self.drawMode = YES;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *colors = [Helpers annotationColors];
        
        self.drawPen = [[AnnotationPen alloc] init];
        self.drawPen.color = [colors objectAtIndex:[[defaults objectForKey:kAnnotationPenColor] intValue]];
        self.drawPen.lineWidth = [defaults objectForKey:kAnnotationPenLineWidth];
        self.drawPen.alpha = [defaults objectForKey:kAnnotationPenAlpha];
        
        self.erasePen = [[AnnotationPen alloc] init];
        self.erasePen.color = [UIColor clearColor];
        self.erasePen.lineWidth = @20;
        self.erasePen.alpha = @1.0F;
        
        self.currentPen = self.drawPen;

        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(draw:)];
        self.panGestureRecognizer.minimumNumberOfTouches = 1;
        self.panGestureRecognizer.maximumNumberOfTouches = 1;
        self.panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.panGestureRecognizer];
        
        self.multiSignSelectRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(selectMultipleSignAnnotations:)];
        self.multiSignSelectRecognizer.minimumNumberOfTouches = 2;
        self.multiSignSelectRecognizer.maximumNumberOfTouches = 2;
        self.multiSignSelectRecognizer.delegate = self;
        [self addGestureRecognizer:self.multiSignSelectRecognizer];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapGestureRecognizer.numberOfTapsRequired = 1;
        self.tapGestureRecognizer.numberOfTouchesRequired = 1;
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        //self.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.1];
    }
    return self;
}


- (void)willDissmissAnnotationsView
{
    [self saveAnnotations];
    
    if (nil != self.penPopoverController) {
        [self.penPopoverController dismissPopoverAnimated:NO];
        self.penPopoverController = nil;
    }
    
    [self.signAnnotations makeObjectsPerformSelector:@selector(hide)];
}

#pragma mark -
#pragma mark Button actions

- (void)segmentedControlTapped
{
    if (nil != self.penPopoverController) {
        [self.penPopoverController dismissPopoverAnimated:NO];
        self.penPopoverController = nil;
    }
    
    EditorViewController *editor = (EditorViewController *)self.delegate;
    editor.containerScrollView.scrollEnabled = NO;
    editor.zoomEnabled = NO;
    
    _annotationInputMode = (AnnotationInputMode) self.inputControlSegment.selectedSegmentIndex;
    
    switch (_annotationInputMode) {
        case AnnotationInputModeDraw:
            self.drawMode = YES;
            self.currentPen = self.drawPen;
            [self endEditingOfTextAnnotation];
            [self removeSignAnnotationInterfaces];
            break;
        
        case AnnotationInputModeType:
            self.drawMode = NO;
            [self removeSignAnnotationInterfaces];
            break;
            
        case AnnotationInputModeSign:
            self.drawMode = NO;
            [self.signAnnotations makeObjectsPerformSelector:@selector(showSignAnnotationMoveViewControllerOnView:) withObject:self];
            break;

        case AnnotationInputModeErase:
            self.drawMode = YES;
            self.currentPen = self.erasePen;
            [self endEditingOfTextAnnotation];
            [self removeSignAnnotationInterfaces];            
            break;    
        case AnnotationInputModeZoom:
            editor.containerScrollView.scrollEnabled = YES;
            editor.zoomEnabled = YES;
            self.drawMode = NO;
            [self endEditingOfTextAnnotation];
            [self removeSignAnnotationInterfaces];            
        default:
            break;
    }
}

- (void)clearTapped
{
    if (nil != self.penPopoverController) {
        [self.penPopoverController dismissPopoverAnimated:NO];
        self.penPopoverController = nil;
    }

    UIAlertView *confirmClearPageAlertView = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"confirmClearPageTitle", nil)
                                                                     message:nil
                                                                    delegate:self 
                                                           cancelButtonTitle:MyLocalizedString(@"buttonCancel", nil) 
                                                           otherButtonTitles:MyLocalizedString(@"buttonOkay", nil), nil];
    [confirmClearPageAlertView show];
}

- (void)penTapped
{
    if (nil == self.penPopoverController) {
        AnnotationsStylePopoverViewController *anPopCon = [[AnnotationsStylePopoverViewController alloc] initWithNibName:@"AnnotationsStylePopoverViewController"
                                                                                                                  bundle:nil];
        anPopCon.delegate = self;
        anPopCon.pen = self.drawPen;
        
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:anPopCon];
        pc.delegate = self;
        [pc setPopoverContentSize:anPopCon.view.frame.size];
        [pc presentPopoverFromBarButtonItem:self.annotationsPenButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        self.penPopoverController = pc;
    }
}

- (void)previousTapped
{
    if (nil != self.penPopoverController) {
        [self.penPopoverController dismissPopoverAnimated:NO];
        self.penPopoverController = nil;
    }

    if ([self.activePage.number intValue] > 1) {
        [self saveAnnotations];
        [self clearPage];
        [self.delegate previousPage];
    }
}

- (void)nextTapped
{
    if (nil != self.penPopoverController) {
        [self.penPopoverController dismissPopoverAnimated:NO];
        self.penPopoverController = nil;
    }

    if ([self.activePage.number intValue] < [[self.activePage.score pages] count] ) {
        [self saveAnnotations];
        [self clearPage];
        [self.delegate nextPage];
    }
}

- (void)showPage:(Page *)thePage
{
    if (nil != self.penPopoverController) {
        [self.penPopoverController dismissPopoverAnimated:NO];
        self.penPopoverController = nil;
    }
    [self saveAnnotations];
    [self clearPage];
    [self.delegate showPage:thePage];
}


#pragma mark -
#pragma mark Custom drawing

- (void)drawRect:(CGRect)rect
{   
    
    // draw the saved paths
    if ([self.drawAnnotations count] > 0) {
        NSDictionary *annotationsDictionary = [self.activePage annotationsDictionaryForFrameSize:self.frame.size invertY:NO];
        NSArray *bezierPaths = [NSArray arrayWithArray:[annotationsDictionary valueForKey:@"bezierPaths"]];
        NSArray *colorsForBezierPaths = [NSArray arrayWithArray:[annotationsDictionary valueForKey:@"colorsForBezierPaths"]];
        NSArray *alphaForBezierPaths = [NSArray arrayWithArray:[annotationsDictionary valueForKey:@"alphaForBezierPaths"]];
        
        for (UIBezierPath *bezierPath in bezierPaths) {
            NSInteger index = [bezierPaths indexOfObject:bezierPath];
            [[colorsForBezierPaths objectAtIndex:index] setStroke];
            [bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:[[alphaForBezierPaths objectAtIndex:index] floatValue]];
        }
    }

    // draw current path
    if (nil != self.drawAnnotation.bezierPath) {
        [self.drawAnnotation.color setStroke];
        [self.drawAnnotation.bezierPath strokeWithBlendMode:kCGBlendModeCopy alpha:[self.drawAnnotation.alpha floatValue]];
    }
    
    for (TextAnnotation *textAnnotation in self.textAnnotations) {
        if (![textAnnotation.hostingView isDescendantOfView:self]) {
            [self addSubview:textAnnotation.hostingView];
#ifdef DEBUG
            NSLog(@"textAnnotation.text: %@", textAnnotation.text);
#endif
        }
    }
    
    for (SignAnnotation *signAnnotation in self.signAnnotations) {
        if (![self.layer.sublayers containsObject:signAnnotation.caLayer]) {
            [self.layer addSublayer:signAnnotation.caLayer];
            if (_annotationInputMode == AnnotationInputModeSign) {
                [signAnnotation showSignAnnotationMoveViewControllerOnView:self];
            }
        }
    }

}

- (void)drawPoint:(CGPoint)point
{
#ifdef DEBUG        
    if ((point.x > self.frameWidth) || (point.x < 0)|| (point.y > self.frameHeight) || (point.y < 0)) {
        NSLog(@"AnnotationsView: drawPoint: Wrong pointOfBezierPath: %@", NSStringFromCGPoint(point));
    }
#endif
    if (nil == self.drawAnnotation) {
        self.drawAnnotation = [[DrawAnnotation alloc] init]; 
        self.drawAnnotation.bezierPath = [UIBezierPath bezierPath];
        self.drawAnnotation.bezierPath.lineWidth = [self.currentPen.lineWidth intValue];
        self.drawAnnotation.color = self.currentPen.color;
        self.drawAnnotation.alpha = self.currentPen.alpha;
        [self.drawAnnotation.bezierPath moveToPoint:point];
    } else {
        [self.drawAnnotation.bezierPath addLineToPoint:point];
    }

    [self setNeedsDisplay];    
}

- (void)endDrawing:(CGPoint)point
{
#ifdef DEBUG        
    if ((point.x > self.frameWidth) || (point.x < 0)|| (point.y > self.frameHeight) || (point.y < 0)) {
        NSLog(@"AnnotationsView: endDrawing: Wrong pointOfBezierPath: %@", NSStringFromCGPoint(point));
    }
#endif
    if (nil != self.drawAnnotation) {
        self.drawAnnotation.originalFrame = [NSValue valueWithCGRect:self.frame];
        self.drawAnnotation.lineWidth = [NSNumber numberWithFloat:self.drawAnnotation.bezierPath.lineWidth];
        [self.drawAnnotation createRelativePointsOfBezierPath];
        [self.drawAnnotations addObject:self.drawAnnotation];
        [self.activePage saveDrawAnnotations:self.drawAnnotations];
        self.drawAnnotation = nil;
    }
}

- (void)addTextAnnotationAtPoint:(CGPoint)point
{
    TextAnnotation *ta = [[TextAnnotation alloc] initWithPoint:point 
                                                         frame:self.frame 
                                                      delegate:self];
    [self addSubview:ta.hostingView];
    [self.textAnnotations addObject:ta];
}

- (BOOL)endEditingOfTextAnnotation
{
    NSIndexSet *result = [self.textAnnotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(TextAnnotation *)obj textField] isEditing];
    }];
    if ([result count] > 0) {
        NSArray *annotationsInEditingMode = [self.textAnnotations objectsAtIndexes:result];        
        [annotationsInEditingMode makeObjectsPerformSelector:@selector(stopEditing)];
        return TRUE;
    } else {
        return FALSE;        
    }
}

- (void)addSignAnnotationAtPoint:(CGPoint)point
{    
    SignAnnotation *signAnnotation = [[SignAnnotation alloc] initWithPoint:point hostingViewFrame:self.frame delegate:self];
    
    [signAnnotation showSignAnnotationViewControllerOnView:self];
    
    [self.signAnnotations addObject:signAnnotation];
}

- (BOOL)endEditingOfSignAnnotation
{
    NSIndexSet *result = [self.signAnnotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [(SignAnnotation *)obj isEditing];
    }];
    if ([result count] > 0) {
        NSArray *annotationsInEditingMode = [self.signAnnotations objectsAtIndexes:result];
        [annotationsInEditingMode makeObjectsPerformSelector:@selector(hideSignAnnotationViewController)];
        return TRUE;
    } else {
        return FALSE;        
    }
}

- (void)removeSignAnnotationInterfaces
{
    [self endEditingOfSignAnnotation];
    [self.signAnnotations makeObjectsPerformSelector:@selector(hideSignAnnotationMoveViewController)];
}

#pragma mark -
#pragma mark Handling touch events

- (void)draw:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (self.drawMode) {
                if (nil != self.delegate && [self.delegate respondsToSelector:@selector(dismissPagePicker)]) {
                    [self.delegate performSelector:@selector(dismissPagePicker)];
                }
                
                CGPoint point = [panGestureRecognizer locationInView:self];
                if ([self pointInside:point withEvent:nil]) {
                    [self drawPoint:point];
                } else {
                    [self endDrawing:point];
                }
            } 
            break;
            
        case UIGestureRecognizerStateChanged:
            if (self.drawMode) {
                CGPoint point = [panGestureRecognizer locationInView:self];
                if ([self pointInside:point withEvent:nil]) {
                    [self drawPoint:point];
                } else {
                    [self endDrawing:point];
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.drawMode) {
                CGPoint point = [panGestureRecognizer locationInView:self];
                [self endDrawing:point];            
            }
            break;
            
        default:
            break;
    }
}


- (void)tap:(UITapGestureRecognizer*)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:self];
    
    switch (tapGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
            
        case UIGestureRecognizerStateChanged:
            break;
            
        case UIGestureRecognizerStateEnded: {
            switch (_annotationInputMode) {
                case AnnotationInputModeType:
                    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(dismissPagePicker)]) {
                        [self.delegate performSelector:@selector(dismissPagePicker)];
                    }
                    
                    if (![self endEditingOfTextAnnotation]) {
                        [self addTextAnnotationAtPoint:point];                        
                    }                
                    break;
                    
                    
                case AnnotationInputModeSign:
                    if ([self endEditingOfSignAnnotation]) {
                        [self.signAnnotations makeObjectsPerformSelector:@selector(showSignAnnotationMoveViewControllerOnView:) withObject:self];
                    } else {
                        [self addSignAnnotationAtPoint:point];                                        
                    }
                    break;
                    
                    
                default:
                    [self endEditingOfTextAnnotation];
                    [self endEditingOfSignAnnotation];
                    break;
            }
            
            
            break;
        }
            
        default:
            break;
    }
    
}

- (void)selectMultipleSignAnnotations:(UIPanGestureRecognizer *)recognizer
{
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        self.multiSignSelection = [NSMutableSet set];
        if (2 == [recognizer numberOfTouches]) {
            [self selectSignsWithPoint1:[recognizer locationOfTouch:0 inView:self]
                                 point2:[recognizer locationOfTouch:1 inView:self]];
        }
	}else if (UIGestureRecognizerStateChanged == recognizer.state) {
        if (2 == [recognizer numberOfTouches]) {
            [self selectSignsWithPoint1:[recognizer locationOfTouch:0 inView:self]
                                 point2:[recognizer locationOfTouch:1 inView:self]];
        }
	}else if (UIGestureRecognizerStateCancelled == recognizer.state) {
        for (SignAnnotation *anAnnotation in self.multiSignSelection) {
            [anAnnotation.signAnnotationMoveViewController setSelected:NO];
        }
        self.multiSignSelection = nil;
    }else if (UIGestureRecognizerStateEnded == recognizer.state) 
    {
        if ([self.multiSignSelection count] == 1) {
            // This annotation is still contained in self.signAnnotations
            // That's why it's ok to show the annotation editor and then trash self.multiSignSelection
            SignAnnotation *selection = [self.multiSignSelection anyObject];
            [selection showSignAnnotationViewControllerOnView:self];
        }else if ([self.multiSignSelection count] > 1) {
            MultipleSignAnnotationViewController *mc = [[MultipleSignAnnotationViewController alloc] initWithSignAnnotations:[self.multiSignSelection allObjects]];
            mc.delegate = self;
            self.multipleSignAnnotationViewController = mc;
            
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:self.multipleSignAnnotationViewController];
            pc.popoverContentSize = self.multipleSignAnnotationViewController.view.frame.size;
            pc.delegate = self;
            
            CGRect lastSaRect = [[[self.multiSignSelection anyObject] caLayer] frame];
            
            [pc presentPopoverFromRect:lastSaRect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.multiSignAnnotationPopoverController = pc;
            
            for (SignAnnotation *anAnnotation in self.multiSignSelection) {
                [anAnnotation.signAnnotationMoveViewController setSelected:NO];
            }
            
            // you need to retain autorelease self.multiSignSelection when handing it off
            // because it gets released straight away.
            
        }
        self.multiSignSelection = nil;
    }
}

- (void)selectSignsWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
    CGFloat rise = fabsf(point1.y - point2.y);
    CGFloat run = fabsf(point1.x - point2.x);
    CGFloat maxDelta = MAX(rise, run);
    
    CGFloat xTick, yTick;
    if (rise > run) {
        xTick = run / rise;
        yTick = 1;
    }else {
        xTick = 1;
        yTick = rise / run;
    }
    if (point1.x > point2.x) {
        xTick *= -1;
    }
    if (point1.y > point2.y) {
        yTick *= -1;
    }
    
    for (int i = 1; i <= maxDelta; i++) {
        CGPoint ptOnLine = CGPointMake(roundf(point1.x + xTick * i),
                                       roundf(point1.y + yTick * i));
        
        /*
         UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot.png"]] autorelease];
         imageView.center = ptOnLine;
         [self addSubview:imageView];
         //NSLog(@"%@", NSStringFromCGPoint(ptOnLine));
         */
        
        
        for (SignAnnotation *anAnnotation in self.signAnnotations) {
            if ([anAnnotation isKindOfClass:[SignAnnotation class]] && 
                CGRectContainsPoint(anAnnotation.signAnnotationMoveViewController.view.frame, ptOnLine)) 
            {
                [anAnnotation.signAnnotationMoveViewController setSelected:YES];
                [self.multiSignSelection addObject:anAnnotation];
            }
        }
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isEqual:_panGestureRecognizer]) {
        if (AnnotationInputModeDraw == self.inputControlSegment.selectedSegmentIndex ||
            AnnotationInputModeErase == self.inputControlSegment.selectedSegmentIndex)
        {
            return YES;
        }else {
            return NO;
        }
    }
    
    if ([gestureRecognizer isEqual:self.multiSignSelectRecognizer]) {
        if (AnnotationInputModeSign == _annotationInputMode) {
            return YES;
        }else {
            return NO;
        } 
    }
    
    if ([gestureRecognizer isEqual:self.tapGestureRecognizer]) {
        if (AnnotationInputModeSign == _annotationInputMode || AnnotationInputModeType == _annotationInputMode) {
            if ([touch.view isKindOfClass:[UIButton class]]) {
                return NO;
            }
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}


#pragma mark -
#pragma mark Data methods

- (void)activePageDidChange:(Page *)page
{
    self.activePage = page;
    
    [self restoreAnnotations];
    
    [self setNeedsDisplay];
}

- (void)clearPage
{
    [self.textAnnotations makeObjectsPerformSelector:@selector(remove)];
    [self.textAnnotations removeAllObjects];
    
    [self.signAnnotations makeObjectsPerformSelector:@selector(hide)];
    [self.signAnnotations removeAllObjects];    
    
    [self.drawAnnotations removeAllObjects];
    self.drawAnnotation = nil;
    
    [self setNeedsDisplay];
}

- (void)saveAnnotations
{
    [self.textAnnotations makeObjectsPerformSelector:@selector(stopEditing)];
    [self removeSignAnnotationInterfaces];
    
    [self.activePage saveDrawAnnotations:self.drawAnnotations];
    [self.activePage saveTextAnnotations:self.textAnnotations];
    [self.activePage saveSignAnnotations:self.signAnnotations];
    
    [[ScoreManager sharedInstance] saveTheFuckingContext];
}

- (void)restoreAnnotations
{
    if (nil == self.activePage.drawAnnotationsData) {
        self.drawAnnotations = [[NSMutableArray alloc] init];
    } else {
        self.drawAnnotations = [self.activePage restoreDrawAnnotations];
    }
    
    if (nil == self.activePage.textAnnotationsData) {
        self.textAnnotations = [[NSMutableArray alloc] init];
    } else {
        self.textAnnotations = [self.activePage restoreTextAnnotations];
        NSDictionary *argumentsDictionary = @{
                kTextAnnotationSetupArgumentFrame : [NSValue valueWithCGRect:self.frame],
                kTextAnnotationSetupArgumentDelegate : self,
                kTextAnnotationSetupArgumentInvertY : @NO
        };
        [self.textAnnotations makeObjectsPerformSelector:@selector(setupWithArgumentsDictionary:)
                                              withObject:argumentsDictionary];
    }
    
    if (nil == self.activePage.signAnnotationsData) {
        self.signAnnotations = [[NSMutableArray alloc] init];
    } else {
        self.signAnnotations = [self.activePage restoreSignAnnotations];
        NSDictionary *argumentsDictionary = @{
                kSignAnnotationSetupArgumentFrame : [NSValue valueWithCGRect:self.frame],
                kSignAnnotationSetupArgumentDelegate : self,
                kSignAnnotationSetupArgumentInvertY : @NO
        };
        [self.signAnnotations makeObjectsPerformSelector:@selector(setupWithArgumentsDictionary:)
                                              withObject:argumentsDictionary];
    }
}

#pragma mark -
#pragma mark AnnotationsStylePopoverViewControllerDelegate

- (void)penDidChange:(AnnotationPen *)newPen
{
    if (self.drawMode) {
        self.currentPen = newPen;
    }
    self.drawPen = newPen;
}

#pragma mark -
#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self clearPage];
        [self.activePage saveDrawAnnotations:self.drawAnnotations];
        [self.activePage saveTextAnnotations:self.textAnnotations];
    }
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([popoverController isEqual:self.penPopoverController]) {
        self.penPopoverController = nil;
    } else if ([popoverController isEqual:self.multiSignAnnotationPopoverController]) {
        MultipleSignAnnotationViewController *mc =  (MultipleSignAnnotationViewController*)self.multiSignAnnotationPopoverController.contentViewController;
        [mc showMoveViewControllersOnView:self];
        self.multiSignAnnotationPopoverController = nil;
    }
}

#pragma mark -
#pragma mark TextAnnotationDelegate

- (void)removeTextAnnotation:(TextAnnotation*)textAnnotation
{
    [self.textAnnotations removeObject:textAnnotation];
}

- (void)startedEditing:(TextAnnotation*)textAnnotation
{
    self.inputControlSegment.selectedSegmentIndex = AnnotationInputModeType;
    self.drawMode = NO;
}

#pragma mark -
#pragma mark SignAnnotationDelegate

- (void)removeSignAnnotation:(SignAnnotation*)signAnnotation
{
    [self.signAnnotations removeObject:signAnnotation];
}

#pragma mark - Rotation

- (void)configureForFrame:(CGRect)frame
{
    self.frameSize = frame.size;
    [self.textAnnotations makeObjectsPerformSelector:@selector(resetWithFrame:)
                                          withObject:[NSValue valueWithCGRect:frame]];
    [self.signAnnotations makeObjectsPerformSelector:@selector(resetHostingViewFrame:)
                                          withObject:[NSValue valueWithCGRect:frame]];
}


#pragma mark - MultipleSignAnnotationViewControllerDelegate

- (void)dismissMultipleSignAnnotationViewController
{
    [self.multiSignAnnotationPopoverController dismissPopoverAnimated:YES];
}


@end
