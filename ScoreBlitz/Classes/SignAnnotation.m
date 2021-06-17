//
//  SignAnnotation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 14.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SignAnnotation.h"
#import "SVGKit.h"
#import "AnnotationsView.h"
#import "SignAnnotationViewController.h"
#import "SignAnnotationMoveViewController.h"

@implementation SignAnnotation

typedef struct {
	CGMutablePathRef path;
 	CGFloat sX;
 	CGFloat sY;
} PathInfo;

@synthesize caLayer, signName;
@synthesize signImage;
@synthesize delegate;
@synthesize color;
@synthesize signAnnotationViewController, signAnnotationMoveViewController;
@synthesize hostingViewFrame, bounds, relativeBounds, position, relativePosition, originalBounds;
@synthesize svgDocument;
@synthesize _popoverController;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithPoint:(CGPoint)newPoint hostingViewFrame:(CGRect)newFrame delegate:(AnnotationsView*)annotationsViewDelegate
{
    self = [super init];
    if (self) {
        position = [NSValue valueWithCGPoint:newPoint];
        hostingViewFrame = [NSValue valueWithCGRect:newFrame];
        delegate = annotationsViewDelegate;                
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSignAnnotationViewControllerAndShowSignAnnotationMoveViewController) name:kHideSignAnnotationViewController object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    signName = [aDecoder decodeObjectForKey:@"signName"];
    color = [aDecoder decodeObjectForKey:@"color"];
    hostingViewFrame = [aDecoder decodeObjectForKey:@"hostingViewFrame"];
    bounds = [aDecoder decodeObjectForKey:@"bounds"];
    relativeBounds = [aDecoder decodeObjectForKey:@"relativeBounds"];
    position = [aDecoder decodeObjectForKey:@"position"];
    relativePosition = [aDecoder decodeObjectForKey:@"relativePosition"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSignAnnotationViewControllerAndShowSignAnnotationMoveViewController) name:kHideSignAnnotationViewController object:nil];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.signName forKey:@"signName"];
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:self.hostingViewFrame forKey:@"hostingViewFrame"];
    [aCoder encodeObject:self.bounds forKey:@"bounds"];
    [aCoder encodeObject:self.relativeBounds forKey:@"relativeBounds"];
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.relativePosition forKey:@"relativePosition"];
}

#pragma mark -
#pragma mark Interface

- (void)show
{
    [self.delegate.layer addSublayer:self.caLayer];
}

- (void)hide
{
    [self.caLayer removeFromSuperlayer];
    [self hideSignAnnotationViewController];
    [self hideSignAnnotationMoveViewController];
}

- (void)showSignAnnotationViewControllerOnView:(UIView*)view
{
    if (nil == self.signAnnotationViewController) {
        signAnnotationViewController = [[SignAnnotationViewController alloc] initWithNibName:@"SignAnnotationViewController" bundle:nil];
        signAnnotationViewController.delegate = self;
    }
    
    if (nil == self.signName) {
        NSString *signAnnotationCategoryKey = [[Helpers signAnnotationCategoryKeys] objectAtIndex:0];
        NSString *signAnnotationKey = [[Helpers signAnnotationKeysForCategory:signAnnotationCategoryKey] objectAtIndex:0];
        
        // setup calayer
        self.color = [UIColor blackColor];
        [self changeLayerToSign:signAnnotationKey];
        
        // make sure the sign is drawn into view bounds
        CGPoint point = [self.position CGPointValue];
        CGFloat signWidth = [self.bounds CGRectValue].size.width;
        CGFloat signHeight = [self.bounds CGRectValue].size.height;
        
        if (point.x < signWidth / 2) {
            point.x = roundf(signWidth / 2);
        } else if (view.frameWidth - point.x < signWidth / 2) {
            point.x = roundf(view.frameWidth - signWidth / 2);
        }
        
        if (point.y < signHeight / 2) {
            point.y = roundf(signHeight / 2);
        } else if (view.frameHeight - point.y < signHeight / 2) {
            point.y = roundf(view.frameHeight - signHeight / 2);
        }

        // show calayer
        [self changeLayerBoundsToRect:[self.bounds CGRectValue]];
        [self changeLayerPositionToPoint:point];
        [self show];
        
        self.signAnnotationViewController.newSignAnnotationAdded = YES;
    }
    
    [self hideSignAnnotationMoveViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideSignAnnotationViewController object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideSignAnnotationViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSignAnnotationViewControllerAndShowSignAnnotationMoveViewController) name:kHideSignAnnotationViewController object:nil];
    
    UIPopoverController *popCon = [[UIPopoverController alloc] initWithContentViewController:self.signAnnotationViewController];
    popCon.popoverContentSize = self.signAnnotationViewController.view.frame.size;
    popCon.delegate = self;

    [popCon presentPopoverFromRect:self.caLayer.frame inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self._popoverController = popCon;
    
    
    //[self.signAnnotationViewController showOnView:view];    
}

- (void)hideSignAnnotationViewController
{
    if (nil != self.signAnnotationViewController) {
        [self.signAnnotationViewController willDismissViewController];
        [self._popoverController dismissPopoverAnimated:YES];
        self.signAnnotationViewController = nil;
    }
}

- (void)hideSignAnnotationViewControllerAndShowSignAnnotationMoveViewController
{
    [self hideSignAnnotationViewController];
    [self showSignAnnotationMoveViewControllerOnView:self.delegate];
}

- (void)showSignAnnotationMoveViewControllerOnView:(UIView*)view
{
    
    if (nil == self.signAnnotationMoveViewController) {
        signAnnotationMoveViewController = [[SignAnnotationMoveViewController alloc] initWithNibName:@"SignAnnotationMoveViewController" bundle:nil];
        signAnnotationMoveViewController.delegate = self;
    }
        
    [self.signAnnotationMoveViewController showOnView:view atPoint:[self.position CGPointValue]];
}

- (void)hideSignAnnotationMoveViewController
{
    if (nil != self.signAnnotationMoveViewController) {
        [self.signAnnotationMoveViewController.view removeFromSuperview];
        self.signAnnotationMoveViewController = nil;
    }
}

- (BOOL)isEditing
{
    if (nil != self._popoverController) {
        return YES;
    } else {
        return NO;
    }
}

- (void)deleteSelf
{
    [self hide];
    [self.delegate removeSignAnnotation:self];
}

#pragma mark -
#pragma mark Data methods

- (void)setupWithArgumentsDictionary:(NSDictionary*)argumentsDictionary
{
    self.hostingViewFrame = [argumentsDictionary valueForKey:kSignAnnotationSetupArgumentFrame];
    CGRect newFrame = [self.hostingViewFrame CGRectValue];
    self.delegate = [argumentsDictionary valueForKey:kSignAnnotationSetupArgumentDelegate];
    BOOL invertY = [[argumentsDictionary valueForKey:kSignAnnotationSetupArgumentInvertY] boolValue];
    
    CGPoint newPosition;
    CGPoint relativePositionPoint = [self.relativePosition CGPointValue];
    newPosition.x = roundf(relativePositionPoint.x * newFrame.size.width);
    if (invertY) {
        newPosition.y = roundf(newFrame.size.height - (relativePositionPoint.y * newFrame.size.height));
    } else {
        newPosition.y = roundf(relativePositionPoint.y * newFrame.size.height);
    }
    
    CGRect relativeBoundsRect = [self.relativeBounds CGRectValue];
    CGRect newBounds = CGRectMake(relativeBoundsRect.origin.x * newFrame.size.width, relativeBoundsRect.origin.y * newFrame.size.height, relativeBoundsRect.size.width * newFrame.size.width, relativeBoundsRect.size.height * newFrame.size.height);
    
    [self changeLayerToSign:self.signName];
    [self changeLayerBoundsToRect:newBounds];
    [self changeLayerPositionToPoint:newPosition];
}

- (void)resetHostingViewFrame:(NSValue*)newFrameValue
{
    self.hostingViewFrame = newFrameValue;
    CGRect newFrame = [newFrameValue CGRectValue];
    
    CGPoint newPosition;
    CGPoint relativePositionPoint = [self.relativePosition CGPointValue];
    newPosition.x = roundf(relativePositionPoint.x * newFrame.size.width);
    newPosition.y = roundf(relativePositionPoint.y * newFrame.size.height);

    CGRect relativeBoundsRect = [self.relativeBounds CGRectValue];
    CGRect newBounds = CGRectMake(relativeBoundsRect.origin.x * newFrame.size.width, relativeBoundsRect.origin.y * newFrame.size.height, relativeBoundsRect.size.width * newFrame.size.width, relativeBoundsRect.size.height * newFrame.size.height);
    
    [self changeLayerBoundsToRect:newBounds];
    [self changeLayerPositionToPoint:newPosition];
    
    if (nil != self.signAnnotationMoveViewController) {
        [self showSignAnnotationMoveViewControllerOnView:self.signAnnotationMoveViewController.view.superview];
    }
}

- (CALayer*)changeLayerToSign:(NSString*)newSignName
{
    self.signName = newSignName;
    
    if (nil != [self.caLayer superlayer]) {
        [self.caLayer removeFromSuperlayer];
    }    

    self.caLayer = [CALayer layer];
    caLayer.needsDisplayOnBoundsChange = YES;
    caLayer.delegate = self;
    
    self.svgDocument = [SVGDocument documentNamed:[newSignName stringByAppendingPathExtension:@"svg"]];
    
    self.bounds = [NSValue valueWithCGRect:CGRectMake(0, 0, self.svgDocument.width, self.svgDocument.height)];
    self.originalBounds = self.bounds;

    return self.caLayer;
}


- (void)createRelativePosition
{
    if (nil == self.hostingViewFrame) {
#ifdef DEBUG        
        [NSException raise:@"Cannot create RelativePosition" format:@"Set frame first!"];
#endif
    } else if (nil == self.position) {
#ifdef DEBUG        
        [NSException raise:@"Cannot create RelativePosition" format:@"Set position first!"];
#endif        
    }
    
    CGSize size = [self.hostingViewFrame CGRectValue].size;
    
    CGPoint relativePoint = [self.position CGPointValue];
    relativePoint.x = relativePoint.x / size.width;
    relativePoint.y = relativePoint.y / size.height;
#ifdef DEBUG        
    if ((relativePoint.x > 1) || (relativePoint.x < 0)|| (relativePoint.y > 1) || (relativePoint.y < 0)) {
        NSLog(@"%s: Wrong position: %@", __func__, NSStringFromCGPoint(relativePoint));
    }
#endif    
    self.relativePosition = [NSValue valueWithCGPoint:relativePoint];
}

- (void)createRelativeBounds
{
    CGSize size = [self.hostingViewFrame CGRectValue].size;

    CGPoint relativeBoundsOrigin = [self.bounds CGRectValue].origin;
    relativeBoundsOrigin.x = relativeBoundsOrigin.x / size.width;
    relativeBoundsOrigin.y = relativeBoundsOrigin.y / size.height;
    
    CGSize relativeBoundsSize = [self.bounds CGRectValue].size;
    relativeBoundsSize.width =  relativeBoundsSize.width / size.width;
    relativeBoundsSize.height = relativeBoundsSize.height / size.height;
    
    self.relativeBounds = [NSValue valueWithCGRect:CGRectMake(relativeBoundsOrigin.x, relativeBoundsOrigin.y, relativeBoundsSize.width, relativeBoundsSize.height)];
}

- (void)changeLayerBoundsToRect:(CGRect)newRect
{
    [CATransaction setDisableActions:YES];     
    self.caLayer.bounds = newRect;
    self.bounds = [NSValue valueWithCGRect:newRect];
    [self createRelativeBounds];
}

- (void)changeLayerPositionToPoint:(CGPoint)newPoint
{
    [CATransaction setDisableActions:YES]; 
    self.caLayer.position = newPoint;
    self.position = [NSValue valueWithCGPoint:newPoint];
    [self createRelativePosition];
}

- (void)changeLayerFrameToRect:(CGRect)newRect
{
    [CATransaction setDisableActions:YES];     
    self.caLayer.frame = newRect;
    self.bounds = [NSValue valueWithCGRect:self.caLayer.bounds];
    self.position = [NSValue valueWithCGPoint:self.caLayer.position];
    [self createRelativeBounds];
    [self createRelativePosition];
}

- (void)fitLayerIntoFrame:(CGRect)newFrame
{
    CGRect layerBounds = [self.bounds CGRectValue];
    CGFloat scaleX = newFrame.size.width / layerBounds.size.width;
    CGFloat scaleY = newFrame.size.height / layerBounds.size.height;
    CGFloat scale = scaleX < scaleY ? scaleX : scaleY;
    [self changeLayerBoundsToRect:CGRectMake(0, 0, roundf(layerBounds.size.width * scale), roundf(layerBounds.size.height * scale))];
}

#pragma mark -
#pragma mark CALayer Delegate



- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CGSize layerSize = [self.bounds CGRectValue].size;
    
    NSArray *svgShapeElements = [self.svgDocument svgShapeElements];
    CGSize svgDocumentSize = CGSizeMake(svgDocument.width, svgDocument.height);
    
    for (SVGShapeElement *shapeElement in svgShapeElements) {        
        // scale the path accordingly to the context change
        CGFloat scaleX = layerSize.width / svgDocumentSize.width;
        CGFloat scaleY = layerSize.height / svgDocumentSize.height;
        CGAffineTransform pathTransform = CGAffineTransformMakeScale(scaleX, scaleY);
        
        //CGPathRef convertedPath = [self convertPath:shapeElement.path FromSize:svgDocumentSize toSize:contextSize];
        CGPathRef convertedPath = CGPathCreateCopyByTransformingPath(shapeElement.path, &pathTransform);
        
        // draw the path into context
        CGContextAddPath(context, convertedPath);
        CGContextSetLineWidth(context, shapeElement.strokeWidth);   
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetAlpha(context, shapeElement.opacity);
        
        CGContextDrawPath(context, kCGPathStroke);
        
        if (shapeElement.fillType == SVGFillTypeSolid) {
            CGContextAddPath(context, convertedPath);
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            
            CGContextDrawPath(context, kCGPathFill);
        }
        
        CGPathRelease(convertedPath);
    }
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([popoverController isEqual:self._popoverController]) {
        self._popoverController = nil;
        [self showSignAnnotationMoveViewControllerOnView:self.delegate];
    }

}
@end
