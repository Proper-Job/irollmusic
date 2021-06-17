//
//  PagePickerScrollView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Score, PagePickerItemView, PagePickerScrollView, Page;


@protocol PickerScrollViewDelegate <NSObject>
- (void)pickerScrollViewDidHide:(PagePickerScrollView *)thePickerScrollView;
- (void)pickerScrollViewSelectionDidChange:(Page *)newSelection;
@end

@interface PagePickerScrollView : UIScrollView <UIScrollViewDelegate> {

@protected
    NSMutableSet *_recycledItems, *_visibleItems;
    NSArray *_orderedPagesAsc;
}
@property (nonatomic, weak) id <PickerScrollViewDelegate> pickerDelegate;
@property (nonatomic, strong) Score *activeScore;
@property (nonatomic, assign) PagePickerShowAnimation showAnimation;
@property (nonatomic, weak) UIView *theSuperview;
@property (nonatomic, weak) IBOutlet PagePickerItemView *itemView;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, strong) Page *activePage;


- (id)init;
- (void)showInView:(UIView *)theView 
      belowToolbar:(UIToolbar *)theToolbar 
     withAnimation:(PagePickerShowAnimation)theAnimation;
- (void)hideAnimated:(BOOL)animated;
- (void)viewControllerPageSelectionDidChange;
- (NSArray *)orderedPagesAsc;
- (void)pagePickerButtonPressedWithPage:(Page *)thePage;


#define kPickerHeightHorizontal 195
#define kPickerWidthVertical 140
#define kPickerXPickerPaddingVertical 5
#define kPickerShowHideAnimationDuration .35
#define kPickerItemHeight 185
#define kPickerItemWidth 125
#define kPickerBackgroundAlpha .5
#define kPickerItemOverlayImageAlpha .5

@end


