//
//  TempoToolbarView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TempoToolbarView;

@interface TempoToolbarView : UIView

@property (nonatomic, strong) IBOutlet UILabel *bpmLabel;
@property (nonatomic, strong) IBOutlet UIButton *actionButton;
@property (nonatomic, strong) IBOutlet UIImageView *noteValueImageView;
@property (nonatomic, copy) void(^didReceiveTouchBlock)(TempoToolbarView *sender);

- (IBAction)tap;

@end
