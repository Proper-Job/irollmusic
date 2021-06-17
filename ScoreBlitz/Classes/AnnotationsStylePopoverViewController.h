//
//  AnnotationsStylePopoverViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnnotationsView, AnnotationPen, LinePreviewView;

@interface AnnotationsStylePopoverViewController : UIViewController {
   
}

@property (nonatomic, strong) IBOutlet UISlider *widthSlider;
@property (nonatomic, strong) IBOutlet LinePreviewView *linePreviewView;
@property (nonatomic, strong) IBOutlet UIView *colorDisplay0, *colorDisplay1, *colorDisplay2, *colorDisplay3, *colorDisplay4, *colorDisplay5, *colorDisplay6;
@property (nonatomic, strong) IBOutlet UILabel *label0, *label1, *label2, *label3, *label4, *label5, *label6, *lineWidthLabel;
@property (nonatomic, strong) IBOutlet UIButton *button0, *button1, *button2, *button3, *button4, *button5, *button6;
@property (nonatomic, strong) IBOutlet UIImageView *checkBox0, *checkBox1, *checkBox2, *checkBox3, *checkBox4, *checkBox5, *checkBox6;
@property (nonatomic, strong) AnnotationPen *pen;
@property (nonatomic, strong) NSArray *colors, *names, *buttons, *checkBoxes;
@property (nonatomic, weak) AnnotationsView *delegate;
@property (nonatomic, strong) CAShapeLayer *dashedBorder;

- (IBAction)widthValueChanged;
- (void)colorChanged:(UIControl *)button withEvent:(UIEvent *)event;

@end

@protocol AnnotationsStylePopoverViewControllerDelegate <NSObject>
- (void)penDidChange:(AnnotationPen *)newPen;
@end
