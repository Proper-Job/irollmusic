//
//  MultipleSignAnnotationViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignAnnotationPickerColorView;

@interface MultipleSignAnnotationViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) IBOutlet UIButton *deleteButton, *resetSizeButton;
@property (nonatomic, strong) IBOutlet UISlider *sizeSlider;
@property (nonatomic, strong) IBOutlet UIPickerView *colorPickerView;
@property (nonatomic, strong) IBOutlet SignAnnotationPickerColorView *signAnnotationPickerColorView;

@property (nonatomic, strong) NSArray *selectedSignAnnotations;
@property (nonatomic, strong) NSMutableArray *signAnnotationSizes;
@property (nonatomic, strong) UIPopoverController *_popOverController;

@property (nonatomic, assign) CGFloat _sliderDefaultValue;
@property (nonatomic, weak) id delegate;

- (id)initWithSignAnnotations:(NSArray*)signAnnotations;

- (void)showMoveViewControllersOnView:(UIView*)newView;

- (IBAction)deleteButtonTapped;
- (IBAction)sizeValueChanged;
- (IBAction)resetSizeTapped;


@end

@protocol MultipleSignAnnotationViewControllerDelegate <NSObject>

- (void)dismissMultipleSignAnnotationViewController;

@end
