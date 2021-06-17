//
//  MultipleSignAnnotationViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MultipleSignAnnotationViewController.h"
#import "SignAnnotation.h"
#import "SignAnnotationPickerColorView.h"

@implementation MultipleSignAnnotationViewController

@synthesize deleteButton, resetSizeButton;
@synthesize sizeSlider;
@synthesize colorPickerView;
@synthesize signAnnotationPickerColorView;

@synthesize selectedSignAnnotations;
@synthesize signAnnotationSizes;
@synthesize _popOverController;
@synthesize _sliderDefaultValue;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSignAnnotations:(NSArray*)signAnnotations
{
    self = [super initWithNibName:@"MultipleSignAnnotationViewController" bundle:nil];
    if (self) {
        selectedSignAnnotations = signAnnotations;
        signAnnotationSizes = [NSMutableArray array];
        
        for (SignAnnotation *signAnnotation in selectedSignAnnotations) {
            [signAnnotationSizes addObject:signAnnotation.bounds];
            [signAnnotation hideSignAnnotationMoveViewController];
        }
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.deleteButton setTitle:MyLocalizedString(@"buttonDelete", nil) forState:UIControlStateNormal];
    [self.resetSizeButton setTitle:MyLocalizedString(@"resetSizeButtonTitle", nil) forState:UIControlStateNormal];    
    
    self._sliderDefaultValue = 1.0;
    self.sizeSlider.minimumValue = 0.5;
    self.sizeSlider.maximumValue = 2;
    self.sizeSlider.value = self._sliderDefaultValue;
}

- (void)showMoveViewControllersOnView:(UIView*)newView
{
    [self.selectedSignAnnotations makeObjectsPerformSelector:@selector(showSignAnnotationMoveViewControllerOnView:)
                                                  withObject:newView];
}

#pragma mark - Button Actions

- (IBAction)deleteButtonTapped
{
    [self.selectedSignAnnotations makeObjectsPerformSelector:@selector(deleteSelf)];
    self.selectedSignAnnotations = nil;
    [self.delegate dismissMultipleSignAnnotationViewController];
}

- (IBAction)sizeValueChanged
{
    for (SignAnnotation *signAnnotation in self.selectedSignAnnotations) {
        NSInteger index = [self.selectedSignAnnotations indexOfObject:signAnnotation];
        CGRect layerBounds = [[self.signAnnotationSizes objectAtIndex:index] CGRectValue];
        [signAnnotation changeLayerBoundsToRect:CGRectMake(0, 0, layerBounds.size.width * self.sizeSlider.value, layerBounds.size.height * self.sizeSlider.value)];        
    }
}

- (IBAction)resetSizeTapped
{
    for (SignAnnotation *signAnnotation in self.selectedSignAnnotations) {
        CGRect layerBounds = [signAnnotation.originalBounds CGRectValue];
        [signAnnotation changeLayerBoundsToRect:layerBounds];
        self.sizeSlider.value = self._sliderDefaultValue;        
    }
}

#pragma mark -
#pragma mark UIPickerView dataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
     return [[Helpers annotationColors] count];
}

#pragma mark -
#pragma mark UIPickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    for (SignAnnotation *signAnnotation in self.selectedSignAnnotations) {
        signAnnotation.color = [[Helpers annotationColors] objectAtIndex:row];
        [signAnnotation.caLayer setNeedsDisplay];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
        [[NSBundle mainBundle] loadNibNamed:@"SignAnnotationPickerColorView" owner:self options:nil];
        self.signAnnotationPickerColorView.colorView.backgroundColor = [[Helpers annotationColors] objectAtIndex:row];
        self.signAnnotationPickerColorView.colorNameLabel.text = [[Helpers annotationColorNames] objectAtIndex:row];
        return self.signAnnotationPickerColorView;
}

@end
