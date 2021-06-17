//
//  PagePickerItemView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Page, PagePickerScrollView;

@interface PagePickerItemView : UIView

@property (nonatomic, strong) IBOutlet UIButton *pagePickerButton;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) IBOutlet UILabel *pageNumberLabel;
@property (nonatomic, strong) Page *page;
@property (nonatomic, weak) PagePickerScrollView *pickerScrollView;

- (IBAction)pagePickerButtonPressed;

@end
