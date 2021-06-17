//
//  SignAnnotationMoveViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SignAnnotationMoveViewController.h"
#import "SignAnnotation.h"
#import "PdfView.h"
#import "MagnifierView.h"

@interface SignAnnotationMoveViewController ()
- (void)showBorder;
- (void)hideBorder;
@end

@implementation SignAnnotationMoveViewController

@synthesize _tapGestureRecognizer, _panGestureRecognizer, _longPressGestureRecognizer;
@synthesize _startPoint, _contentStartPoint;
@synthesize _startRect, _contentStartRect, _longPressTouchDownPoint;
@synthesize delegate;
@synthesize _hostingViewSize;
@synthesize magnifierView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self showBorder];
    self.view.exclusiveTouch = YES;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSignAnnotationEditor:)];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeSignAnnotation:)];
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveSignAnnotation:)];
    _longPressGestureRecognizer.minimumPressDuration = 0.5;
    
    [self.view addGestureRecognizer:self._tapGestureRecognizer];
    [self.view addGestureRecognizer:self._panGestureRecognizer];
    [self.view addGestureRecognizer:self._longPressGestureRecognizer];
}

#pragma mark - View actions

- (void)showOnView:(UIView*)newView atPoint:(CGPoint)point                                             
{
    self._hostingViewSize = newView.frame.size;
    CGRect boundsOfLayer = [self.delegate.bounds CGRectValue]; 
    self.view.frame = CGRectMake(0, 0, boundsOfLayer.size.width + kContentOffset, boundsOfLayer.size.height + kContentOffset);
    self.view.center = point;
    [newView addSubview:self.view];
}

- (void)showSignAnnotationEditor:(UITapGestureRecognizer*)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
            
        case UIGestureRecognizerStateChanged:
            break;
            
        case UIGestureRecognizerStateEnded:
            [self.delegate showSignAnnotationViewControllerOnView:self.view.superview];
            break;
            
        default:
            break;
    }

}

- (void)moveSignAnnotation:(UILongPressGestureRecognizer *)gestureRecognizer
{   
    CGPoint dragPoint, offsetToCenter, newCenter;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self._longPressTouchDownPoint = [gestureRecognizer locationInView:self.view];
            
            if (nil == self.magnifierView && self.view.frameWidth < kMaxSignWidth && self.view.frameHeight < kMaxSignHeight) {
                id pdfView = self.view.superview.superview;
                
                if ([pdfView isKindOfClass:[PdfView class]]) {
                    magnifierView = [[MagnifierView alloc] init];
                    
                    magnifierView.frameWidth = MAX(self.view.frameWidth * magnifierView.scaleFactor + 25, magnifierView.frameWidth);
                    magnifierView.frameHeight = MAX(self.view.frameHeight * magnifierView.scaleFactor + 25, magnifierView.frameHeight);

                    magnifierView.viewToMagnify = self.view.superview.superview; 
                    dragPoint = [gestureRecognizer locationInView:self.view.superview];
                    offsetToCenter = CGPointMake(CGRectGetMidX(self.view.bounds) - self._longPressTouchDownPoint.x,
                                                 CGRectGetMidY(self.view.bounds) - self._longPressTouchDownPoint.y);
                    newCenter = CGPointMake(dragPoint.x + offsetToCenter.x, dragPoint.y + offsetToCenter.y);
                    self.magnifierView.touchPoint = newCenter;
                    self.magnifierView.alpha = 0;
                    [self.magnifierView setNeedsDisplay];
                    [self.view.superview addSubview:self.magnifierView];
                }else {
#ifdef DEBUG
                    NSLog(@"can't show magnifying glass as pdf view can't be found, %s %d", __func__, __LINE__);
#endif
                }
                
            }
            
            // grow the view when selected
            [UIView animateWithDuration:0.15 
                             animations:^(void) {
                                 if (nil != self.magnifierView) {
                                     [self hideBorder];
                                     self.magnifierView.alpha = 1;
                                 }else {
                                     [self.view setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
                                 }
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            dragPoint = [gestureRecognizer locationInView:self.view.superview];
            offsetToCenter = CGPointMake(CGRectGetMidX(self.view.bounds) - self._longPressTouchDownPoint.x,
                                         CGRectGetMidY(self.view.bounds) - self._longPressTouchDownPoint.y);
            newCenter = CGPointMake(dragPoint.x + offsetToCenter.x, dragPoint.y + offsetToCenter.y);
            
            
            CGSize layerSize = self.delegate.caLayer.frame.size;
            
            // don't move beyond frame bounds
            if (newCenter.x - layerSize.width/2 < 0) {
                newCenter.x = layerSize.width/2;
            } else if (newCenter.x > (self._hostingViewSize.width - layerSize.width/2)) {
                newCenter.x = roundf(self._hostingViewSize.width - layerSize.width/2);                    
            }
            if (newCenter.y - layerSize.height/2 < 0) {
                newCenter.y = layerSize.height/2;
            } else if (newCenter.y > (self._hostingViewSize.height - layerSize.height/2)){
                newCenter.y = roundf(self._hostingViewSize.height - layerSize.height/2);
            }
            
            [self.delegate changeLayerPositionToPoint:newCenter];            
            self.view.center = newCenter;
            
            //self.magnifierView.touchPoint = dragPoint;
            self.magnifierView.touchPoint = newCenter;
            [self.magnifierView setNeedsDisplay];
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // shrink the textField when selection ended
            [UIView animateWithDuration:0.15 
                             animations:^(void) {
                                 [self.view setTransform:CGAffineTransformIdentity];
                                 self.magnifierView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 if (nil != self.magnifierView) {
                                     [self.magnifierView removeFromSuperview];
                                     self.magnifierView = nil;
                                 }
                                 [self showBorder];    
                             }];
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)resizeSignAnnotation:(UIPanGestureRecognizer*)gestureRecognizer
{
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self._startPoint = [gestureRecognizer locationInView:self.view.superview];
            self._startRect = self.view.frame;
            self._contentStartRect = self.delegate.caLayer.frame;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint newPosition = [gestureRecognizer locationInView:self.view.superview];
            
            CGFloat xOffset = newPosition.x - self._startPoint.x;
            CGFloat yOffset = newPosition.y - self._startPoint.y;
            
            CGFloat contentWidth = roundf(self._contentStartRect.size.width + xOffset);
            CGFloat contentHeight = roundf(self._contentStartRect.size.height + yOffset);
            
            CGFloat moveViewWidth = roundf(self._startRect.size.width + xOffset);
            CGFloat moveViewHeight = roundf(self._startRect.size.height + yOffset);
            
            if (self._startRect.size.width + xOffset < kContentOffset) {
                moveViewWidth = kContentOffset;
                contentWidth = 0;
            }
            if (self._startRect.size.height + yOffset < kContentOffset) {
                moveViewHeight = kContentOffset;
                contentHeight = 0;
            }
            
            if (self._contentStartRect.origin.x + contentWidth > self._hostingViewSize.width) {
                contentWidth = self._hostingViewSize.width - self._contentStartRect.origin.x;
                moveViewWidth = contentWidth + kContentOffset;
            }
            
            if (self._contentStartRect.origin.y + contentHeight > self._hostingViewSize.height) {
                contentHeight = self._hostingViewSize.height - self._contentStartRect.origin.y;
                moveViewHeight = contentHeight + kContentOffset;
            }
            
            CGRect contentRect = CGRectMake(self._contentStartRect.origin.x, self._contentStartRect.origin.y, contentWidth, contentHeight);
            CGRect moveViewRect = CGRectMake(self._startRect.origin.x, self._startRect.origin.y, moveViewWidth, moveViewHeight);
            
            [self.delegate changeLayerFrameToRect:contentRect];            
            self.view.frame = moveViewRect;

            break;
        }
            
        case UIGestureRecognizerStateEnded: {            
            self._startPoint = CGPointZero;
            self._startRect = CGRectZero;
            self._contentStartRect = CGRectZero;

            break;
        }
            
        default:
            break;
    }
}


- (void)setSelected:(BOOL)selected
{
    if (selected) {
        self.view.backgroundColor = [[Helpers lightPetrol] colorWithAlphaComponent:.7];
    }else {
        self.view.backgroundColor = [[Helpers black] colorWithAlphaComponent:0.2];
    }
}

- (void)showBorder {
    self.view.backgroundColor = [[Helpers black] colorWithAlphaComponent:0.2];
    self.view.layer.cornerRadius = 3.0;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [[[Helpers petrol] colorWithAlphaComponent:0.5] CGColor];
}

- (void)hideBorder {
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.cornerRadius = 3.0;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [[UIColor clearColor] CGColor];
}

@end
