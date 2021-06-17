//
//  AnnotationsStylePopoverViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "AnnotationsStylePopoverViewController.h"
#import "AnnotationsView.h"
#import "AnnotationPen.h"
#import "LinePreviewView.h"


@implementation AnnotationsStylePopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Dashed border around white color
        self.dashedBorder = [CAShapeLayer layer];
        self.dashedBorder.strokeColor = [UIColor blackColor].CGColor;
        self.dashedBorder.fillColor = nil;
        self.dashedBorder.lineDashPattern = @[@3, @6];
        self.dashedBorder.lineWidth = .5;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lineWidthLabel.text = MyLocalizedString(@"penLineWidth", nil);
    
    // setup arrays and constants
    self.colors = [Helpers annotationColors];
    
    self.names = [Helpers annotationColorNames];
    self.buttons = @[
            self.button0,
            self.button1,
            self.button2,
            self.button3,
            self.button4,
            self.button5,
            self.button6
    ];
    self.checkBoxes = @[
            self.checkBox0,
            self.checkBox1,
            self.checkBox2,
            self.checkBox3,
            self.checkBox4,
            self.checkBox5,
            self.checkBox6
    ];
    
    // setup buttons
    for (UIButton *button in self.buttons) {
        [button addTarget:self 
                   action:@selector(colorChanged:withEvent:) 
        forControlEvents:UIControlEventTouchUpInside];
    }
    
    // setup checkboxes
    for (UIImageView *imageview in self.checkBoxes) {
        imageview.image = [UIImage imageNamed:@"checkbox_off"];
    }

    // setup color views
    for (UIColor *color in self.colors) {
        int index = [self.colors indexOfObject:color];
        [self setValue:color
            forKeyPath:[NSString stringWithFormat:@"colorDisplay%d.backgroundColor", index]];
        [self setValue:[NSNumber numberWithFloat:kPenPickerColorDisplayCornerRadius] 
            forKeyPath:[NSString stringWithFormat:@"colorDisplay%d.layer.cornerRadius", index]];

        if ([color isEqual:[UIColor whiteColor]]) {
            UIView *whiteView = (UIView *)[self valueForKey:[NSString stringWithFormat:@"colorDisplay%d", index]];
            [whiteView.layer addSublayer:self.dashedBorder];
        }
        // check the box with the selected color
        if ([self.pen.color isEqual:color]) {
            [self setValue:[UIImage imageNamed:@"checkbox_on"]
                forKeyPath:[NSString stringWithFormat:@"checkBox%d.image", index]];
        }
    }
    
    // setup label names
    for (NSString *name in self.names) {
        [self setValue:name forKeyPath:[NSString stringWithFormat:@"label%d.text", [self.names indexOfObject:name]]];
    }

    
    //setup width slider
    self.widthSlider.minimumValue = 1;
    self.widthSlider.maximumValue = 20;
    self.widthSlider.value = [self.pen.lineWidth intValue];
    
    // setup linePreviewView
    self.linePreviewView.pen = self.pen;
    [self.linePreviewView drawPoint:CGPointMake(0, self.linePreviewView.frameHeight / 2) endDrawing:NO];
    [self.linePreviewView drawPoint:CGPointMake(self.linePreviewView.frameWidth, self.linePreviewView.frameHeight / 2) endDrawing:YES];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    int index = [self.colors indexOfObject:[UIColor whiteColor]];
    UIView *whiteView = (UIView *)[self valueForKey:[NSString stringWithFormat:@"colorDisplay%d", index]];
    self.dashedBorder.path = [UIBezierPath bezierPathWithRect:whiteView.bounds].CGPath;
    self.dashedBorder.frame = whiteView.bounds;
}

- (IBAction)widthValueChanged
{
    self.pen.lineWidth = [NSNumber numberWithInt:self.widthSlider.value];
    
    // setup linePreviewView
    [self.linePreviewView clearPage];
    self.linePreviewView.pen = self.pen;
    [self.linePreviewView drawPoint:CGPointMake(0, self.linePreviewView.frameHeight / 2) endDrawing:NO];
    [self.linePreviewView drawPoint:CGPointMake(self.linePreviewView.frameWidth, self.linePreviewView.frameHeight / 2) endDrawing:YES];
    
    [self.delegate penDidChange:self.pen];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.pen.lineWidth forKey:kAnnotationPenLineWidth];
}

- (void)colorChanged:(UIControl *)button withEvent:(UIEvent *)event
{
    UIButton *buttonToFind = nil;
    for (UIButton *theButton in self.buttons) {
        if ([theButton isEqual:button]) {
            buttonToFind = theButton;
        }
    }
    
    if (nil != buttonToFind) {
        NSInteger processingIndex = [self.buttons indexOfObject:buttonToFind];
        self.pen.color = [self.colors objectAtIndex:processingIndex];
        
        // set alpha for textMarker
        if ([self.pen.color isEqual:[UIColor yellowColor]]) {
            self.pen.alpha = @0.5F;
        } else {
            self.pen.alpha = @1.0F;
        }
        
        // set checkboxes
        [self.checkBoxes makeObjectsPerformSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"checkbox_off.png"]];
        [[self.checkBoxes objectAtIndex:processingIndex] setImage:[UIImage imageNamed:@"checkbox_on.png"]];
        
        // setup linePreviewView
        [self.linePreviewView clearPage];
        self.linePreviewView.pen = self.pen;
        [self.linePreviewView drawPoint:CGPointMake(0, self.linePreviewView.frameHeight / 2) endDrawing:NO];
        [self.linePreviewView drawPoint:CGPointMake(self.linePreviewView.frameWidth, self.linePreviewView.frameHeight / 2) endDrawing:YES];

        [self.delegate penDidChange:self.pen];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.pen.alpha forKey:kAnnotationPenAlpha];
        [defaults setObject:[NSNumber numberWithInt:[self.colors indexOfObject:self.pen.color]]
                     forKey:kAnnotationPenColor];
    }
}

@end
