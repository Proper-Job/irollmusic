//
//  ScoreAnalysingViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.01.15.
//
//

#import <UIKit/UIKit.h>

@interface ScoreAnalysingViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *titleLabel, *scoreNameLabel, *progressLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) NSArray *scores;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) NSInteger totalOperations, finishedOperations;
@property (nonatomic, copy) void (^completionBlock)(BOOL success);

- (instancetype)initWithScores:(NSArray*)scores;

@end
