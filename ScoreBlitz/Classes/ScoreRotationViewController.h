//
//  ScoreRotationViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import <UIKit/UIKit.h>

@class Score;

@interface ScoreRotationViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *titleLabel, *progressLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (id)initWithScore:(Score*)score;

@end
