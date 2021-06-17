//
//  ToolbarBackButtonView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 25/03/15.
//
//

#import <UIKit/UIKit.h>

@interface ToolbarBackButtonView : UIView

@property (nonatomic, strong) IBOutlet UILabel *backLabel;
@property (nonatomic, copy) void (^backPressedBlock)(UIButton *sender);

- (IBAction)backPressed:(id)sender;
@end
