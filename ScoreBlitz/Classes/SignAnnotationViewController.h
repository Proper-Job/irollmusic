//
//  SignAnnotationsSelectorViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 14.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignAnnotation, SignAnnotationPickerColorView;

@interface SignAnnotationViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate,
        UIPopoverControllerDelegate>

typedef enum {
    HorizontalPositionLeft,
    HorizontalPositionMiddle,
    HorizontalPositionRight,
} HorizontalPosition;

typedef enum {
    VerticalPositionTop,
    VerticalPositionMiddle,
    VerticalPositionBottom
} VerticalPosition;

@property (nonatomic, strong) IBOutlet UIView *selectorView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *selector;
@property (nonatomic, strong) IBOutlet UIButton *signButton0, *signButton1, *signButton2, *signButton3, *signButton4,
        *signButton5, *signButton6, *signButton7, *signButton8;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton, *resetSizeButton, *infoButton;
@property (nonatomic, strong) IBOutlet UISlider *sizeSlider;
@property (nonatomic, strong) IBOutlet UIPickerView *signAnnotationPickerView, *colorPickerView;
@property (nonatomic, strong) IBOutlet SignAnnotationPickerColorView *signAnnotationPickerColorView;
@property (nonatomic, strong) NSArray *signAnnotationCategoryKeys, *signAnnotationKeys;
@property (nonatomic, strong) NSMutableArray *recentSignAnnotationImages, *recentSignAnnotationKeys,
        *pickerSignAnnotationImages;
@property (nonatomic, strong) NSMutableDictionary *allSignAnnotationImages;
@property (nonatomic, assign) CGRect layerBounds;
@property (nonatomic, assign) CGPoint layerPosition;
@property (nonatomic, assign) CGFloat sliderDefaultValue;
@property (nonatomic, assign) BOOL newSignAnnotationAdded;
@property (nonatomic, strong) UIPopoverController *signAnnotationInfoPopoverController;
@property (nonatomic, weak) SignAnnotation *delegate;

- (void)willDismissViewController;

- (IBAction)infoButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped;
- (IBAction)selectorValueChanged:(id)sender;
- (IBAction)sizeValueChanged;
- (IBAction)resetSizeTapped;
- (IBAction)recentSignAnnotationButtonTapped:(id)sender;

- (void)drawRecentSignAnnotations;

- (NSMutableArray*)signAnnotationImagesForCategoryKey:(NSString*)categoryKey;
- (UIImage*)signAnnotationImageForKey:(NSString*)signAnnotationKey;

@end
