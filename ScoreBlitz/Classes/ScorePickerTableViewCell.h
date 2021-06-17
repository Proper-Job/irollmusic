//
//  ScorePickerTableViewCell.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 10.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundedGradientButton;

@interface ScorePickerTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
