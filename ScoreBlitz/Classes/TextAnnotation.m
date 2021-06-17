//
//  TextAnnotation.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TextAnnotation.h"
#import "AnnotationsView.h"

@implementation TextAnnotation

@synthesize textField, moveButton, hostingView, deleteButton, text, textFontName, textFontSize;
@synthesize originOfHostingView, relativeOriginOfHostingView, originOfTextField, relativeOriginOfTextField, frame;
@synthesize _textFieldWidth, _textFieldHeight, _textFieldFontSize, _deleteButtonWidth, _deleteButtonHeight, _moveButtonWidth, _moveButtonHeight;
@synthesize _hostingViewWidth, _hostingViewHeight, delegate, _locationInView;


- (id)initWithPoint:(CGPoint)newPoint frame:(CGRect)newFrame delegate:(AnnotationsView*)newDelegate
{
    self = [super init];
    if (self) {
        // cache the attributes
        frame = [NSValue valueWithCGRect:newFrame];
        delegate = newDelegate;
        
        [self setTextAnnotationSize];
        
        // create point that is not beyond frame bounds
        CGPoint newOriginOfHostingView = CGPointMake(roundf(newPoint.x - _hostingViewWidth / 2), roundf(newPoint.y - (_hostingViewHeight / 2) - (_textFieldHeight / 2)));
        newOriginOfHostingView = [self adjustPointToFrameBounds:newOriginOfHostingView];
        
        [self createTextAnnotationWithOrigin:newOriginOfHostingView];
                
        // write the values
        originOfHostingView = [NSValue valueWithCGPoint:hostingView.frame.origin];
        [self createRelativeOriginOfHostingView];        
        originOfTextField = [NSValue valueWithCGPoint:CGPointMake(hostingView.frame.origin.x + textField.frame.origin.x, hostingView.frame.origin.y + textField.frame.origin.y)];
        [self createRelativeOriginOfTextField];
        
        [textField becomeFirstResponder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    text = [aDecoder decodeObjectForKey:@"text"];
    textFontName = [aDecoder decodeObjectForKey:@"textFontName"];
    textFontSize = [aDecoder decodeObjectForKey:@"textFontSize"];
    originOfHostingView = [aDecoder decodeObjectForKey:@"originOfHostingView"];
    relativeOriginOfHostingView = [aDecoder decodeObjectForKey:@"relativeOriginOfHostingView"];
    originOfTextField = [aDecoder decodeObjectForKey:@"originOfTextField"];
    relativeOriginOfTextField = [aDecoder decodeObjectForKey:@"relativeOriginOfTextField"];
    frame = [aDecoder decodeObjectForKey:@"frame"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.textFontName forKey:@"textFontName"];
    [aCoder encodeObject:self.textFontSize forKey:@"textFontSize"];
    [aCoder encodeObject:self.originOfHostingView forKey:@"originOfHostingView"];
    [aCoder encodeObject:self.relativeOriginOfHostingView forKey:@"relativeOriginOfHostingView"];
    [aCoder encodeObject:self.originOfTextField forKey:@"originOfTextField"];
    [aCoder encodeObject:self.relativeOriginOfTextField forKey:@"relativeOriginOfTextField"];
    [aCoder encodeObject:self.frame forKey:@"frame"];
}

#pragma mark -
#pragma mark Data methods


- (void)setTextAnnotationSize
{    
    CGSize size = [frame CGRectValue].size;
    
    if (size.height > size.width) {
        _textFieldWidth = roundf(size.width * 0.1854);
        _textFieldHeight = roundf(size.height * 0.0240);
        _textFieldFontSize = roundf(size.height * 0.0152);
        _deleteButtonWidth = roundf(size.width * 0.0463);
        _deleteButtonHeight = roundf(size.height * 0.0327);
        _moveButtonWidth = roundf(size.width * 0.0463);
        _moveButtonHeight = roundf(size.height * 0.0327);
    } else {
        _textFieldWidth = roundf(size.width * 0.1562);
        _textFieldHeight = roundf(size.height * 0.0405);
        _textFieldFontSize = roundf(size.height * 0.0257);
        _deleteButtonWidth = roundf(size.width * 0.0390);
        _deleteButtonHeight = roundf(size.height * 0.0552);
        _moveButtonWidth = roundf(size.width * 0.0390);
        _moveButtonHeight = roundf(size.height * 0.0552);
    }

    _hostingViewWidth = roundf(_deleteButtonWidth + _textFieldWidth + _moveButtonWidth - 10);
    _hostingViewHeight = roundf(_textFieldHeight + _moveButtonHeight);
}


- (void)createTextAnnotationWithOrigin:(CGPoint)newOrigin
{
    // create hosting view for layout textfield und deleteButton
    hostingView = [[UIView alloc] initWithFrame:CGRectMake(newOrigin.x, newOrigin.y, _hostingViewWidth, _hostingViewHeight)];
    hostingView.backgroundColor = [UIColor clearColor];
    //hostingView.backgroundColor = [UIColor blueColor];
    
    // create deleteButton with image
    UIImage *deleteButtonImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"delete" ofType:@"png"]];
    UIImageView *deleteButtonImageView = [[UIImageView alloc] initWithImage:deleteButtonImage];
    deleteButtonImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(0, 0, _deleteButtonWidth, _deleteButtonHeight);
    [deleteButton addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    deleteButtonImageView.frame = deleteButton.frame;
    [deleteButton addSubview:deleteButtonImageView];
    
    // setup moveButton
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveTextFieldAnnotation:)];
    gestureRecognizer.minimumPressDuration = 0.5;
    gestureRecognizer.cancelsTouchesInView = YES;
    
    moveButton = [[UIView alloc] initWithFrame:CGRectMake(_textFieldWidth + _deleteButtonWidth - 10, 0, _moveButtonWidth, _moveButtonHeight)];
    moveButton.backgroundColor = [[Helpers babyBlue] colorWithAlphaComponent:0.5];
    moveButton.layer.cornerRadius = 15.0;
    moveButton.layer.borderColor = [[[UIColor blueColor] colorWithAlphaComponent:0.5] CGColor];
    moveButton.layer.borderWidth = 1.0;
    [moveButton addGestureRecognizer:gestureRecognizer];
    
    
    // setup annotation textField
    textField = [[UITextField alloc] initWithFrame:CGRectMake(_deleteButtonWidth - 5, _deleteButtonHeight, _textFieldWidth, _textFieldHeight)];
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:_textFieldFontSize];
    textField.minimumFontSize = 10.0;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.layer.cornerRadius = 5.0;
    textField.layer.borderWidth = 1.0;
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textField.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:249.0/255.0 blue:229.0/255.0 alpha:1];
    textFontName = textField.font.fontName;
    textFontSize = [NSNumber numberWithFloat:_textFieldFontSize];
    
    // setup hosting view
    [hostingView addSubview:textField];
    [hostingView addSubview:deleteButton];
    [hostingView addSubview:moveButton];
}


- (CGPoint)adjustPointToFrameBounds:(CGPoint)pointToCheck
{
    CGSize size = [frame CGRectValue].size;
    
    if (pointToCheck.x < 0) {
        pointToCheck.x = 0;
    } else if (pointToCheck.x > (size.width - _hostingViewWidth)) {
        pointToCheck.x = roundf(size.width - _hostingViewWidth);
    }
    if (pointToCheck.y < 0) {
        pointToCheck.y = 0;
    } else if (pointToCheck.y > size.height - _hostingViewHeight){
        pointToCheck.y = roundf(size.height - _hostingViewHeight);
    }
    
    return pointToCheck;
}

- (void)createRelativeOriginOfTextField
{
    CGSize size;
    
    if (nil == self.frame) {
#ifdef DEBUG        
        [NSException raise:@"Cannot create RelativeOriginOfTextField" format:@"Set frame first!"];
#endif
    } else if (nil == self.originOfTextField) {
#ifdef DEBUG        
        [NSException raise:@"Cannot create RelativeOriginOfTextField" format:@"Set originOfTextField first!"];
#endif        
    } else {
        size = [self.frame CGRectValue].size;
    }
    
    CGPoint point = [self.originOfTextField CGPointValue];
    point.x = point.x / size.width;
    point.y = point.y / size.height;
#ifdef DEBUG        
    if ((point.x > 1) || (point.x < 0)|| (point.y > 1) || (point.y < 0)) {
        NSLog(@"Wrong pointOfTextField: %@", NSStringFromCGPoint(point));
    }
#endif    
    self.relativeOriginOfTextField = [NSValue valueWithCGPoint:point];
}

- (void)createRelativeOriginOfHostingView
{
    CGSize size;
    
    if (nil == self.frame) {
#ifdef DEBUG        
        [NSException raise:@"Cannot create createRelativeOriginOfHostingView" format:@"Set frame first!"];
#endif
    } else if (nil == self.originOfHostingView) {
#ifdef DEBUG        
        [NSException raise:@"Cannot create createRelativeOriginOfHostingView" format:@"Set originOfHostingView first!"];
#endif        
    } else {
        size = [self.frame CGRectValue].size;
    }
    
    CGPoint point = [self.originOfHostingView CGPointValue];
    point.x = point.x / size.width;
    point.y = point.y / size.height;
#ifdef DEBUG        
    if ((point.x > 1) || (point.x < 0)|| (point.y > 1) || (point.y < 0)) {
        NSLog(@"Wrong pointOfTextField: %@", NSStringFromCGPoint(point));
    }
#endif    
    self.relativeOriginOfHostingView = [NSValue valueWithCGPoint:point];
}

- (void)setupWithArgumentsDictionary:(NSDictionary*)argumentsDictionary
{
    self.frame = [argumentsDictionary valueForKey:kTextAnnotationSetupArgumentFrame];
    CGRect newFrame = [self.frame CGRectValue];
    self.delegate = [argumentsDictionary valueForKey:kTextAnnotationSetupArgumentDelegate];
    BOOL invertY = [[argumentsDictionary valueForKey:kTextAnnotationSetupArgumentInvertY] boolValue];
    [self setTextAnnotationSize];
    
    CGPoint newOriginTF;
    CGPoint relativeOriginTF = [self.relativeOriginOfTextField CGPointValue];
    newOriginTF.x = roundf(relativeOriginTF.x * newFrame.size.width);
    if (invertY) {
        newOriginTF.y = roundf(newFrame.size.height - (relativeOriginTF.y * newFrame.size.height));
    } else {
        newOriginTF.y = roundf(relativeOriginTF.y * newFrame.size.height);
    }
    self.originOfTextField = [NSValue valueWithCGPoint:newOriginTF];
    
    CGPoint newOriginHV;
    CGPoint relativeOriginHV = [self.relativeOriginOfHostingView CGPointValue];
    newOriginHV.x = roundf(relativeOriginHV.x * newFrame.size.width);
    if (invertY) {
        newOriginHV.y = roundf(newFrame.size.height - (relativeOriginHV.y * newFrame.size.height));
    } else {
        newOriginHV.y = roundf(relativeOriginHV.y * newFrame.size.height);
    }
    self.originOfHostingView = [NSValue valueWithCGPoint:newOriginHV];
    
    [self createTextAnnotationWithOrigin:[self.originOfHostingView CGPointValue]];
    self.textField.text = self.text;
}

- (void)resetWithFrame:(NSValue*)newFrameValue
{
    self.frame = newFrameValue;
    CGRect newFrame = [newFrameValue CGRectValue];
    
    [self setTextAnnotationSize];
    
    CGPoint newOriginTF;
    CGPoint relativeOriginTF = [self.relativeOriginOfTextField CGPointValue];
    newOriginTF.x = roundf(relativeOriginTF.x * newFrame.size.width);
    newOriginTF.y = roundf(relativeOriginTF.y * newFrame.size.height);

    self.originOfTextField = [NSValue valueWithCGPoint:newOriginTF];
    
    CGPoint newOriginHV;
    CGPoint relativeOriginHV = [self.relativeOriginOfHostingView CGPointValue];
    newOriginHV.x = roundf(relativeOriginHV.x * newFrame.size.width);
    newOriginHV.y = roundf(relativeOriginHV.y * newFrame.size.height);

    self.originOfHostingView = [NSValue valueWithCGPoint:newOriginHV];
    self.hostingView.frame = CGRectMake(newOriginHV.x, newOriginHV.y, _hostingViewWidth, _hostingViewHeight);
    self.deleteButton.frame = CGRectMake(0, 0, _deleteButtonWidth, _deleteButtonHeight);
    self.moveButton.frame = CGRectMake(_textFieldWidth + _deleteButtonWidth - 10, 0, _moveButtonWidth, _moveButtonHeight);
    self.textField.frame = CGRectMake(_deleteButtonWidth - 5, _deleteButtonHeight, _textFieldWidth, _textFieldHeight);
    self.textField.font = [UIFont systemFontOfSize:_textFieldFontSize];
    self.textFontSize = [NSNumber numberWithFloat:textField.font.pointSize];
}


- (NSNumber*)relativeFontSizeForSize:(CGSize)newSize
{
    CGSize originalSize = [self.frame CGRectValue].size;
    
    CGFloat scale = newSize.width / originalSize.width;
    
    return [NSNumber numberWithFloat:([self.textFontSize floatValue] * scale)];
}

#pragma mark -
#pragma mark Button Actions

- (void)moveTextFieldAnnotation:(UILongPressGestureRecognizer *)gestureRecognizer
{    
    CGPoint positionAnnotationsView;
    CGPoint positionToMoveTo;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            // grow the textField when selected
            [UIView animateWithDuration:0.15 
                             animations:^(void) {
                                 [self.hostingView setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
                             }
                             completion:^(BOOL finished) {
                                 self.hostingView.frame = CGRectMake(roundf(self.hostingView.frameOrigin.x), roundf(self.hostingView.frameOrigin.y), roundf(self.hostingView.frameWidth), roundf(self.hostingView.frameHeight));
                                 
                                 // cache the first touch point
                                 _locationInView = [gestureRecognizer locationInView:self.hostingView];
                             }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // calculate new position
            positionAnnotationsView = [gestureRecognizer locationInView:[self.hostingView superview]];
            positionToMoveTo = CGPointMake(roundf(positionAnnotationsView.x - _locationInView.x*1.2), roundf(positionAnnotationsView.y - _locationInView.y*1.2));
            
            CGSize size = [frame CGRectValue].size;
            
            // don't move beyond frame bounds
            if (positionToMoveTo.x < 0) {
                positionToMoveTo.x = 0;
            } else if (positionToMoveTo.x > (size.width - self.hostingView.frameWidth)) {
                positionToMoveTo.x = roundf(size.width - self.hostingView.frameWidth);                    
            }
            if (positionToMoveTo.y < 0) {
                positionToMoveTo.y = 0;
            } else if (positionToMoveTo.y > size.height - self.hostingView.frameHeight){
                positionToMoveTo.y = roundf(size.height - self.hostingView.frameHeight);
            }
            
            // set new position
            [self.hostingView setFrameOrigin:positionToMoveTo];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // shrink the textField when selection ended
            [UIView animateWithDuration:0.15 
                             animations:^(void) {
                                 [[self.textField superview] setTransform:CGAffineTransformIdentity];
                             }
                             completion:^(BOOL finished) {
                                 self.hostingView.frame = CGRectMake(roundf(hostingView.frameOrigin.x), roundf(hostingView.frameOrigin.y), hostingView.frameWidth, hostingView.frameHeight);
                                 self.originOfHostingView = [NSValue valueWithCGPoint:hostingView.frame.origin];
                                 [self createRelativeOriginOfHostingView];
                                 
                                 self.originOfTextField = [NSValue valueWithCGPoint:CGPointMake(self.hostingView.frame.origin.x + self.textField.frame.origin.x, self.hostingView.frame.origin.y + self.textField.frame.origin.y)];
                                 [self createRelativeOriginOfTextField];
                                 
                                 _locationInView.x = 0;
                                 _locationInView.y = 0;}];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)remove
{
    [self.hostingView removeFromSuperview];
    [self.delegate removeTextAnnotation:self];
}

- (void)stopEditing
{
    [self.textField resignFirstResponder];
}

#pragma mark -
#pragma mark UITextField delegate


- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
    [self.delegate startedEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField
{
        self.text = theTextField.text;
        self.textFontName = theTextField.font.fontName;
        self.textFontSize = [NSNumber numberWithFloat:theTextField.font.pointSize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
	[theTextField resignFirstResponder];
	return YES;
}


@end
