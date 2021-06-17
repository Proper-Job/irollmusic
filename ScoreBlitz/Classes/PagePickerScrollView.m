//
//  PagePickerScrollView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PagePickerScrollView.h"
#import "Score.h"
#import "PagePickerItemView.h"
#import "Page.h"

@interface PagePickerScrollView ()
@property (nonatomic, weak) UIToolbar *_theToolbar;

- (CGRect)hiddenFrame;
- (CGRect)visibleFrame;
- (void)drawPages;
- (BOOL)isDisplayingItemForIndex:(NSUInteger)index;
- (PagePickerItemView *)dequeueRecycledItem;
- (void)configurePickerItem:(PagePickerItemView *)pickerItemView 
			 forIndex:(NSUInteger)index;
- (PagePickerItemView *)pickerItemForPage:(Page *)thePage;
- (PagePickerItemView *)loadPickerItem;
@end


@implementation PagePickerScrollView

@synthesize showAnimation, activeScore, pickerDelegate, theSuperview, itemView,
padding, activePage;

@synthesize _theToolbar;

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.delegate = self;
        
        _visibleItems = [[NSMutableSet alloc] init];
        _recycledItems = [[NSMutableSet alloc] init];
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;        
        self.backgroundColor = [UIColor clearColor];
         
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
            .05, .14, .16, .9,  // Start color
            .05, .14, .16, .3// End color
    };
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint startGradient, endGradient, startPoint, endPoint;
    if (PagePickerShowAnimationFromTop == showAnimation)
    {
        startGradient = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
        endGradient = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
        
        startPoint = CGPointMake(0.0f,  CGRectGetMaxY(currentBounds) -1);
        endPoint = CGPointMake(CGRectGetMaxX(currentBounds), CGRectGetMaxY(currentBounds) -1);
    }else if (PagePickerShowAnimationFromBottom == showAnimation) {
        startGradient = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
        endGradient = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
        
        startPoint = CGPointMake(0.0f,  1);
        endPoint = CGPointMake(CGRectGetMaxX(currentBounds), 1);
    }else {
        startGradient = CGPointMake(0.0f, CGRectGetMidY(currentBounds));
        endGradient = CGPointMake(CGRectGetMaxX(currentBounds), CGRectGetMidY(currentBounds));
        
        startPoint = CGPointMake(CGRectGetMaxX(currentBounds) -1, CGRectGetMinY(currentBounds));
        endPoint = CGPointMake(CGRectGetMaxX(currentBounds) -1, CGRectGetMaxY(currentBounds));
    }

    // Draw the gradient
    CGContextDrawLinearGradient(currentContext, glossGradient, startGradient, endGradient, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace); 
    
    
    // Draw the finish line
    CGFloat lineColor[4] = {
            .05, .14, .16, .9
    };
    CGContextSetStrokeColor(currentContext, lineColor);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    CGContextStrokePath(currentContext);

}

#pragma mark -
#pragma mark Presenting the Picker


- (void)showInView:(UIView *)theView 
      belowToolbar:(UIToolbar *)theToolbar 
     withAnimation:(PagePickerShowAnimation)theAnimation
{
    self.theSuperview = theView; // Should this be retained? No.
    self.showAnimation = theAnimation;
    self._theToolbar = theToolbar;
    self.frame = [self hiddenFrame];
    CGRect activePageRect;
    
    if (PagePickerShowAnimationFromTop == theAnimation || 
        PagePickerShowAnimationFromBottom == theAnimation)
    {
        self.contentSize = CGSizeMake( [self.activeScore.pages count] * kPickerItemWidth, self.frame.size.height);
        activePageRect =  CGRectMake([[self orderedPagesAsc] indexOfObject:activePage] * kPickerItemWidth,
                                     0, kPickerItemWidth, kPickerItemHeight);
    }else {
        self.contentSize = CGSizeMake( self.frame.size.width, [self.activeScore.pages count] * kPickerItemHeight);
        activePageRect = CGRectMake(kPickerXPickerPaddingVertical, 
                                    [[self orderedPagesAsc] indexOfObject:activePage] * kPickerItemHeight,
                                    kPickerItemWidth, kPickerItemHeight);
    }

    [self scrollRectToVisible:activePageRect animated:NO];
    [self drawPages];
    if (nil != theToolbar) {
        [theSuperview insertSubview:self belowSubview:theToolbar];
    }else {
        [theSuperview addSubview:self];
    }
    
    
    [UIView animateWithDuration:kPickerShowHideAnimationDuration
                     animations:^(void){
                         self.frame = [self visibleFrame]; 
                     }];
}

- (void)hideAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? kPickerShowHideAnimationDuration : 0
                     animations:^(void) {
                         self.frame = [self hiddenFrame];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         if (nil != self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(pickerScrollViewDidHide:)]) {
                             [self.pickerDelegate pickerScrollViewDidHide:self]; 
                         }
                     }];
}

- (CGRect)hiddenFrame
{
    CGRect superviewBounds = self.theSuperview.bounds;
    if (PagePickerShowAnimationFromTop == showAnimation) {
        return CGRectMake(superviewBounds.origin.x,
                          -kPickerHeightHorizontal,
                          superviewBounds.size.width,
                          kPickerHeightHorizontal);
    }else if (PagePickerShowAnimationFromBottom == showAnimation) {
        return CGRectMake(superviewBounds.origin.x,
                          superviewBounds.size.height,
                          superviewBounds.size.width,
                          kPickerHeightHorizontal);
    }else if (PagePickerShowAnimationFromLeft == showAnimation) {
        return CGRectMake(-kPickerWidthVertical,
                          self._theToolbar.frameHeight + self._theToolbar.frameY,
                          kPickerWidthVertical, 
                          superviewBounds.size.height - (2 * self._theToolbar.frameHeight) - self._theToolbar.frameY);
    }else if (PagePickerShowAnimationFromRight == showAnimation) {
        return CGRectMake(superviewBounds.size.width,
                          padding,
                          kPickerWidthVertical,
                          superviewBounds.size.height - padding);
    }else {
        return CGRectZero;
    }
}

- (CGRect)visibleFrame
{
    CGRect superviewBounds = self.theSuperview.bounds;
    if (PagePickerShowAnimationFromTop == showAnimation) {
        return CGRectMake(self.frameOrigin.x, padding, self.frameWidth, self.frameHeight);
    }else if (PagePickerShowAnimationFromBottom == showAnimation) {
        return CGRectMake(self.frameOrigin.x, 
                          superviewBounds.size.height - self.frameHeight - self._theToolbar.frameHeight,
                          self.frameWidth,
                          self.frameHeight);
    }else if (PagePickerShowAnimationFromLeft == showAnimation) {
        return CGRectMake(0, self.frameOrigin.y, self.frameWidth, self.frameHeight);
    }else if (PagePickerShowAnimationFromRight == showAnimation) {
        return CGRectMake(superviewBounds.size.width - self.frameWidth, self.frameOrigin.y, self.frameWidth, self.frameHeight);
    }else {
        return CGRectZero;
    }
}


#pragma mark -
#pragma mark Scrollview Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self drawPages];
}

- (void)drawPages
{
    // Calculate which pages are visible
    CGRect visibleBounds = self.bounds;
    if (CGRectEqualToRect(visibleBounds, CGRectZero)) {
        return;
    }
    
    int firstNeededPageIndex, lastNeededPageIndex;
    if (PagePickerShowAnimationFromTop == showAnimation || 
        PagePickerShowAnimationFromBottom == showAnimation)
    {
        firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / kPickerItemWidth);
        lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / kPickerItemWidth);
    }else {
        firstNeededPageIndex = floorf(CGRectGetMinY(visibleBounds) / kPickerItemHeight);
        lastNeededPageIndex  = floorf((CGRectGetMaxY(visibleBounds)-1) / kPickerItemHeight);
    }
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self.activeScore.pages count] - 1);
    //NSLog(@"first page: %d last page: %d", firstNeededPageIndex, lastNeededPageIndex);
    
    // Recycle no-longer-visible pages 
    for (PagePickerItemView *pickerItem in _visibleItems) {
        if (pickerItem.index < firstNeededPageIndex || pickerItem.index > lastNeededPageIndex) {
            [_recycledItems addObject:pickerItem];
            [pickerItem removeFromSuperview];
            pickerItem.imageView.image = nil;
            pickerItem.pageNumberLabel.text = nil;
            pickerItem.page = nil;
        }
    }
    [_visibleItems minusSet:_recycledItems];

    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingItemForIndex:index]) {
            PagePickerItemView *pickerItem = [self dequeueRecycledItem];
            if (nil == pickerItem) {
                pickerItem = [self loadPickerItem];
            }
            [self configurePickerItem:pickerItem forIndex:index];
            [self addSubview:pickerItem];
            [_visibleItems addObject:pickerItem];
        }
    }
}


- (void)configurePickerItem:(PagePickerItemView *)pickerItemView 
                   forIndex:(NSUInteger)index
{
	pickerItemView.index = index;
    if (PagePickerShowAnimationFromTop == showAnimation ||
        PagePickerShowAnimationFromBottom == showAnimation) 
    {
        pickerItemView.frameX = kPickerItemWidth * index;
        pickerItemView.frameY = kPickerHeightHorizontal - kPickerItemHeight;
    }else {
        pickerItemView.frameY = kPickerItemHeight * index;
        pickerItemView.frameX = kPickerXPickerPaddingVertical;
    }
    
    Page *page = self.orderedPagesAsc[index];
    
    pickerItemView.page = page;
    UIImage *previewImage = [page previewImageSmall];
    pickerItemView.imageView.image = previewImage;
    
    pickerItemView.overlayView.frame = [self frameForImage:previewImage
                                      inImageViewAspectFit:pickerItemView.imageView];
    if ([page isEqual:activePage]) {
        pickerItemView.overlayView.alpha = 0;
    }else {
        pickerItemView.overlayView.alpha = kPickerItemOverlayImageAlpha;
    }
    
    pickerItemView.pageNumberLabel.text = [NSString stringWithFormat:@"%d", index + 1];
    pickerItemView.pagePickerButton.tag = index;
}


- (PagePickerItemView *)dequeueRecycledItem
{
    PagePickerItemView *item = (PagePickerItemView *)[_recycledItems anyObject];
    if (nil != item) {
        [_recycledItems removeObject:item];
    }
    return item;
}

- (BOOL)isDisplayingItemForIndex:(NSUInteger)index
{
	for (PagePickerItemView *item in _visibleItems) {
		if (item.index == index) {
			return YES;
		}
	}
	return NO;
}

- (CGRect)frameForImage:(UIImage *)image inImageViewAspectFit:(UIImageView *)imageView
{
    float imageRatio = image.size.width / image.size.height;

    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;

    if(imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;

        float width = scale * image.size.width;

        float topLeftX = (imageView.frame.size.width - width) * 0.5f;

        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;

        float height = scale * image.size.height;

        float topLeftY = (imageView.frame.size.height - height) * 0.5f;

        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}

#pragma mark - Updating the Picker

- (void)pagePickerButtonPressedWithPage:(Page *)thePage
{
    if (![thePage isEqual:self.activePage]) {
        self.activePage = thePage;
        [self viewControllerPageSelectionDidChange];
        if (nil != self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(pickerScrollViewSelectionDidChange:)]) {
            [self.pickerDelegate pickerScrollViewSelectionDidChange:self.activePage];
        }
    }

}

- (void)viewControllerPageSelectionDidChange
{
    PagePickerItemView *item = [self pickerItemForPage:activePage];
    if (nil == item) {
        item = [self dequeueRecycledItem];
        if (nil == item) {
            item = [self loadPickerItem];
        }        
        [self configurePickerItem:item
                         forIndex:[activePage.number unsignedIntegerValue] -1];
        [_visibleItems addObject:item];
        [self addSubview:item];
    }
    for (PagePickerItemView *theItem in _visibleItems) {
        if ([activePage isEqual:theItem.page]) {
            theItem.overlayView.alpha = 0;
            [self scrollRectToVisible:item.frame animated:YES];
        }else {
            theItem.overlayView.alpha = kPickerItemOverlayImageAlpha;
        }
    }
}

- (PagePickerItemView *)pickerItemForPage:(Page *)thePage
{
    for (PagePickerItemView *item in _visibleItems) {
        if ([item.page isEqual:thePage]) {
            return item;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Utilities

- (NSArray *)orderedPagesAsc
{
    if (nil == _orderedPagesAsc) {
        _orderedPagesAsc = [self.activeScore orderedPagesAsc];
    }
    return _orderedPagesAsc;
}

- (PagePickerItemView *)loadPickerItem
{
    [[NSBundle mainBundle] loadNibNamed:@"PagePickerItemView" owner:self options:nil];
    PagePickerItemView *item = self.itemView;
    self.itemView = nil;
    [item.imageView addSubview:item.overlayView]; // can't do this in IB for some reason
    item.pickerScrollView = self;
    return item;
}

- (void)setShowAnimation:(PagePickerShowAnimation)newShowAnimation
{
    showAnimation = newShowAnimation;
    
    switch (showAnimation) {
        case PagePickerShowAnimationFromTop:
            self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
            break;
        case PagePickerShowAnimationFromBottom:
            self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            break;
        case PagePickerShowAnimationFromLeft:
            self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
            break;
        case PagePickerShowAnimationFromRight:
            self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Memory Management


@end
