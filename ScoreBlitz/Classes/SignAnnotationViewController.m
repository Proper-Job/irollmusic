//
//  SignAnnotationsSelectorViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 14.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SignAnnotationViewController.h"
#import "SignAnnotation.h"
#import "SettingsManager.h"
#import "SignAnnotationPickerColorView.h"
#import "EditorViewController.h"
#import "HelpViewPopOverViewController.h"

@implementation SignAnnotationViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { 
        self.signAnnotationCategoryKeys = [Helpers signAnnotationCategoryKeys];
        self.signAnnotationKeys = [Helpers signAnnotationKeysForCategory:self.signAnnotationCategoryKeys[0]];
        self.newSignAnnotationAdded = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(observeEditorAnimationToInterfaceOrientation:) 
                                                     name:kWillAnimateRotationToInterfaceOrientation 
                                                   object:nil];

    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // view setup
    self.view.exclusiveTouch = YES;
    
    //setup sigAnnotation keys
    NSString *signAnnotationKey = self.delegate.signName;
    NSString *signAnnotationCategoryKey = [Helpers signAnnotationCategoryForSignAnnotation:signAnnotationKey];        
    self.signAnnotationKeys = [Helpers signAnnotationKeysForCategory:signAnnotationCategoryKey];
    self.pickerSignAnnotationImages = [self signAnnotationImagesForCategoryKey:signAnnotationCategoryKey];
    
    if (nil == self.delegate.caLayer) {
        [self.delegate changeLayerToSign:signAnnotationKey];
    }
    self.layerBounds = [self.delegate.bounds CGRectValue];
    self.layerPosition = [self.delegate.position CGPointValue];
    
    //setup picker for colors
    UIPickerView *cp = [[UIPickerView alloc] initWithFrame:self.signAnnotationPickerView.frame];
    cp.showsSelectionIndicator = YES;
    cp.delegate = self;
    cp.dataSource = self;
    self.colorPickerView = cp;
    
    // set button titles
    [self.deleteButton setTitle:MyLocalizedString(@"buttonDelete", nil) forState:UIControlStateNormal];
    [self.selector setTitle:MyLocalizedString(@"signAnnotationModeSign", nil) forSegmentAtIndex:0];
    [self.selector setTitle:MyLocalizedString(@"signAnnotationModeColor", nil) forSegmentAtIndex:1];
    [self.resetSizeButton setTitle:MyLocalizedString(@"resetSizeButtonTitle", nil) forState:UIControlStateNormal];
    
    self.sliderDefaultValue = 1.0;
    self.sizeSlider.minimumValue = 0.5;
    self.sizeSlider.maximumValue = 2;
    self.sizeSlider.value = self.sliderDefaultValue;

    for (int counter = 0; counter < kMaxRecentSignAnnotations; counter++) {
        UIButton *button = [self valueForKey:[NSString stringWithFormat:@"signButton%d", counter]];
        button.layer.cornerRadius = 1.0;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [self drawRecentSignAnnotations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
       
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *signAnnotationKey = self.delegate.signName;
    if (nil != signAnnotationKey) {
        NSString *signAnnotationCategoryKey = [Helpers signAnnotationCategoryForSignAnnotation:signAnnotationKey];
        self.signAnnotationKeys = [Helpers signAnnotationKeysForCategory:signAnnotationCategoryKey];
        
        [self.signAnnotationPickerView selectRow:[self.signAnnotationCategoryKeys indexOfObject:signAnnotationCategoryKey] inComponent:0 animated:NO];
        [self.signAnnotationPickerView selectRow:[self.signAnnotationKeys indexOfObject:signAnnotationKey] inComponent:1 animated:NO];
    } 
}

- (void)willDismissViewController
{
    if (self.newSignAnnotationAdded) {
        [[SettingsManager sharedInstance] pushSignAnnotationKeyToRecentSignAnnotations:self.delegate.signName];
    }
}



#pragma mark - Button actions

- (IBAction)infoButtonTapped:(id)sender
{
    if (nil == self.signAnnotationInfoPopoverController) {
        HelpViewPopOverViewController *controller = [[HelpViewPopOverViewController alloc] initWithTemplate:MyLocalizedString(@"popoverHelpTemplateSignAnnotations", nil)
                                                                                                controlItem:sender
                                                                                        webViewFinishedLoad:^(id controlItem)
        {
            [self.signAnnotationInfoPopoverController presentPopoverFromRect:self.infoButton.frame
                                                           inView:self.view
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
        }];
        self.signAnnotationInfoPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.signAnnotationInfoPopoverController.delegate = self;
        [controller loadContent];
    }

}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController { // Is not called in response to programatic dismissal
    if ([popoverController isEqual:self.signAnnotationInfoPopoverController]) {
        self.signAnnotationInfoPopoverController.delegate = nil;
        self.signAnnotationInfoPopoverController = nil;
    }
}

- (void)observeEditorAnimationToInterfaceOrientation:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[EditorViewController class]] && nil != self.signAnnotationInfoPopoverController) {
        self.signAnnotationInfoPopoverController.delegate = nil;
        [self.signAnnotationInfoPopoverController dismissPopoverAnimated:YES];
        self.signAnnotationInfoPopoverController = nil;
    }
}


- (IBAction)deleteButtonTapped
{
    [self.delegate deleteSelf];
}

- (IBAction)selectorValueChanged:(id)sender
{
    if (self.selector.selectedSegmentIndex == 0) {
        NSString *signAnnotationKey = self.delegate.signName;
        if (nil != signAnnotationKey) {
            NSString *signAnnotationCategoryKey = [Helpers signAnnotationCategoryForSignAnnotation:signAnnotationKey];
            self.signAnnotationKeys = [Helpers signAnnotationKeysForCategory:signAnnotationCategoryKey];
            
            [self.signAnnotationPickerView selectRow:[self.signAnnotationCategoryKeys indexOfObject:signAnnotationCategoryKey]
                                         inComponent:0
                                            animated:NO];
            [self.signAnnotationPickerView selectRow:[self.signAnnotationKeys indexOfObject:signAnnotationKey]
                                         inComponent:1
                                            animated:NO];
        }
        
        [UIView transitionFromView:self.colorPickerView
                            toView:self.signAnnotationPickerView duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:NULL];
    } else {
        [self.colorPickerView selectRow:[[Helpers annotationColors] indexOfObject:self.delegate.color]
                            inComponent:0
                               animated:NO];
        [UIView transitionFromView:self.signAnnotationPickerView
                            toView:self.colorPickerView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        completion:NULL];
    }    
}

- (IBAction)sizeValueChanged
{
    [self.delegate changeLayerBoundsToRect:CGRectMake(
            0,
            0,
            roundf(self.layerBounds.size.width * self.sizeSlider.value),
            roundf(self.layerBounds.size.height * self.sizeSlider.value))];
}

- (IBAction)resetSizeTapped
{
    self.layerBounds = [self.delegate.originalBounds CGRectValue];
    [self.delegate changeLayerBoundsToRect:self.layerBounds];
    self.sizeSlider.value = self.sliderDefaultValue;
}

- (IBAction)recentSignAnnotationButtonTapped:(id)sender
{
    for (int counter = 0; counter < kMaxRecentSignAnnotations; counter++) {
        UIButton *button = [self valueForKey:[NSString stringWithFormat:@"signButton%d", counter]];
        if ([button isEqual:sender]) {
            if (counter < [self.recentSignAnnotationKeys count]) {
                NSString *signAnnotationKey = self.recentSignAnnotationKeys[counter];
                
                NSString *signAnnotationCategoryKey = [Helpers signAnnotationCategoryForSignAnnotation:signAnnotationKey];
                
                [self.signAnnotationPickerView selectRow:[self.signAnnotationCategoryKeys
                        indexOfObject:signAnnotationCategoryKey]
                                             inComponent:0
                                                animated:YES];
                [self pickerView:self.signAnnotationPickerView didSelectRow:[self.signAnnotationCategoryKeys
                        indexOfObject:signAnnotationCategoryKey] inComponent:0];
                
                [self.signAnnotationPickerView selectRow:[self.signAnnotationKeys indexOfObject:signAnnotationKey] inComponent:1 animated:YES];
                [self pickerView:self.signAnnotationPickerView didSelectRow:[self.signAnnotationKeys indexOfObject:signAnnotationKey] inComponent:1];
            }
        }
    }
}

#pragma mark - View actions

- (void)drawRecentSignAnnotations
{
    self.recentSignAnnotationKeys = [NSMutableArray arrayWithArray:[[SettingsManager sharedInstance] recentSignAnnotations]];
    self.recentSignAnnotationImages = [NSMutableArray array];
    
    for (NSString *signAnnotationKey in self.recentSignAnnotationKeys) {
        [self.recentSignAnnotationImages addObject:[self signAnnotationImageForKey:signAnnotationKey]];
    }
    
    for (UIImage *signAnnotationImage in self.recentSignAnnotationImages) {
        NSInteger index = [self.recentSignAnnotationImages indexOfObject:signAnnotationImage];
        UIButton *button = [self valueForKey:[NSString stringWithFormat:@"signButton%d", index]];
        [button setImage:signAnnotationImage forState:UIControlStateNormal];
    }
}

#pragma mark - Data methods


- (NSMutableArray*)signAnnotationImagesForCategoryKey:(NSString*)categoryKey
{
    NSArray *signAnnotationsKeys = [Helpers signAnnotationKeysForCategory:categoryKey];
    NSMutableArray *signAnnotationImages = [NSMutableArray array];
    
    for (NSString *signAnnotationKey in signAnnotationsKeys) {
        [signAnnotationImages addObject:[self signAnnotationImageForKey:signAnnotationKey]];
    }
    
    return signAnnotationImages;
}

- (UIImage*)signAnnotationImageForKey:(NSString*)signAnnotationKey
{
    if (nil == self.allSignAnnotationImages) {
        NSArray *signAnnotationCategoryKeys = [Helpers signAnnotationCategoryKeys];
        self.allSignAnnotationImages = [NSMutableDictionary dictionary];

        for (NSString *categoryKey in signAnnotationCategoryKeys) {
            NSArray *signAnnotationKeys = [Helpers signAnnotationKeysForCategory:categoryKey];
            NSMutableDictionary *signAnnotationImages = [NSMutableDictionary dictionary];
            
            for (NSString *signAnnotationKey in signAnnotationKeys) {
                UIImage *signImage = [UIImage imageNamed:[signAnnotationKey stringByAppendingPathExtension:@"png"]];                
                signAnnotationImages[signAnnotationKey] = signImage;
            }

            self.allSignAnnotationImages[categoryKey] = signAnnotationImages;
        }
    }
    
    NSString *categoryKey = [Helpers signAnnotationCategoryForSignAnnotation:signAnnotationKey];
    NSMutableDictionary *imageDictionary = self.allSignAnnotationImages[categoryKey];
    UIImage *signAnnotationImage = imageDictionary[signAnnotationKey];

    return signAnnotationImage;
}

#pragma mark -
#pragma mark UIPickerView dataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:self.signAnnotationPickerView]) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.signAnnotationPickerView]) {
        switch (component) {
            case 0: {
                return [self.signAnnotationCategoryKeys count];
                break;                
                }
                
            case 1: {
                return [self.signAnnotationKeys count];
                break;                
            }
                
            default:
                return 0;
                break;
        }
    } else {
        return [[Helpers annotationColors] count];
    }
}

#pragma mark -
#pragma mark UIPickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.signAnnotationPickerView]) {
        switch (component) {
            case 0: {
                NSString *categoryKey = self.signAnnotationCategoryKeys[row];
                self.signAnnotationKeys = [Helpers signAnnotationKeysForCategory: categoryKey];
                self.pickerSignAnnotationImages = [self signAnnotationImagesForCategoryKey:categoryKey];
                [self.signAnnotationPickerView reloadComponent:1];
                [self.signAnnotationPickerView selectRow:0 inComponent:1 animated:YES];
                [self pickerView:self.signAnnotationPickerView didSelectRow:0 inComponent:1];
                break;            
            }
                
            case 1: {
                NSString *newSignAnnotationKey = self.signAnnotationKeys[row];
                [self.delegate changeLayerToSign:newSignAnnotationKey];
                [self.delegate changeLayerPositionToPoint:self.layerPosition];
                [self.delegate changeLayerBoundsToRect:[self.delegate.originalBounds CGRectValue]];
                [self.delegate show];            
                self.layerBounds = [self.delegate.bounds CGRectValue];
                break;            
            }
                
            default:
                break;
        }
    } else {
        self.delegate.color = [Helpers annotationColors][row];
        [self.delegate.caLayer setNeedsDisplay];
    }
        
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if ([pickerView isEqual:self.signAnnotationPickerView]) {        
        switch (component) {
            case 0: {
                if (nil == view) {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
                    label.backgroundColor = [UIColor clearColor];
                    label.text = [Helpers signAnnotationCategoryNameForKey:self.signAnnotationCategoryKeys[row]];
                    return label;                    
                } else {
                    UILabel *label = (UILabel*)view;
                    label.text = [Helpers signAnnotationCategoryNameForKey:self.signAnnotationCategoryKeys[row]];
                    return label;                    
                }
            }

            case 1: {
                NSString *signAnnotationKey = self.signAnnotationKeys[row];
                if (nil == view) {
                    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[self signAnnotationImageForKey:signAnnotationKey]];
                    return newImageView;
                } else {
                    UIImageView *imageView = (UIImageView*)view;
                    imageView.image = [self signAnnotationImageForKey:signAnnotationKey];
                    [imageView sizeToFit];
                    return imageView;
                }
            }
                
            default:
                return nil;
        }
    } else {
        if (nil == view) {
            [[NSBundle mainBundle] loadNibNamed:@"SignAnnotationPickerColorView" owner:self options:nil];
            self.signAnnotationPickerColorView.colorView.backgroundColor = [Helpers annotationColors][row];
            self.signAnnotationPickerColorView.colorNameLabel.text = [Helpers annotationColorNames][row];
            return self.signAnnotationPickerColorView;
        } else {
            SignAnnotationPickerColorView *colorView = (SignAnnotationPickerColorView*)view;
            colorView.colorView.backgroundColor = [Helpers annotationColors][row];
            colorView.colorNameLabel.text = [Helpers annotationColorNames][row];
            return colorView;
        }
    }
}

@end
