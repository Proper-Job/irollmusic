//
//  ScoreAnalysingViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.01.15.
//
//

#import "ScoreAnalysingViewController.h"
#import "Score.h"
#import "ScoreAnalysingOperation.h"
#import "SleepManager.h"

#define kScoreAnalysingViewControllerSleepIdentifier @"ScoreAnalysingViewController"

@interface ScoreAnalysingViewController ()

@end

@implementation ScoreAnalysingViewController

- (instancetype)initWithScores:(NSArray*)scores
{
    self = [super initWithNibName:@"ScoreAnalysingViewController" bundle:nil];
    if (self) {
        self.scores = scores;
        self.totalOperations = [scores count];
        self.finishedOperations = 0;
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 5;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAnalysingNotification) name:kCancelScoreImportNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.scores count] > 0) {
        self.titleLabel.text = MyLocalizedString(@"MultipleScoresAnalysingProgressMessage", nil);
    } else {
        self.titleLabel.text = MyLocalizedString(@"analysingProgress", nil);
    }
    
    self.scoreNameLabel.text = @"";
    self.progressLabel.text = @"0 %";
    
    self.progressView.progressTintColor = [Helpers petrol];
    self.progressView.progress = 0;
    
    [self.cancelButton setTitle:MyLocalizedString(@"buttonCancel", nil) forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [Helpers petrol];
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor];

    if ([self.scores count] > 0) {
        [[SleepManager sharedInstance] addInsomniac:kScoreAnalysingViewControllerSleepIdentifier];
    }
    
    for (Score *score in self.scores) {
        ScoreAnalysingOperation *scoreAnalysingOperation = [[ScoreAnalysingOperation alloc] initWithObjectID:score.objectID];
        [scoreAnalysingOperation setProgressBlock:^(NSString *scoreName, CGFloat progress) {
            [self updateAnalysingProgress:progress scoreName:scoreName];
        }];
        [scoreAnalysingOperation setCompletionBlockWithSuccess:^(NSManagedObjectID *scoreId) {
            [self analysingOperationSuccess:scoreId];
        } failure:^(NSManagedObjectID *scoreId) {
            [self analysingOperationFailure:scoreId];
        }];
        
        [self.operationQueue addOperation:scoreAnalysingOperation];
    }
}


#pragma mark - Button Actions

- (IBAction)cancelTapped:(id)sender
{
    [self.operationQueue cancelAllOperations];
    [[SleepManager sharedInstance] removeInsomniac:kScoreAnalysingViewControllerSleepIdentifier];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.completionBlock) {
            self.completionBlock(NO);
        }
    }];
}

#pragma mark - ScoreAnalysingOperation CallBacks

- (void)updateAnalysingProgress:(CGFloat)progress scoreName:(NSString*)scoreName
{
    CGFloat fullProgress = 0;
    
    if (self.totalOperations == 1) {
        self.scoreNameLabel.text = scoreName;
        fullProgress = progress;
    } else {
        fullProgress = 1.0 / (float)self.totalOperations * (float)self.finishedOperations;        
    }
    
    int intProgress = (int)roundf(fullProgress * 100);
    self.progressLabel.text = [NSString stringWithFormat:@"%d %%", intProgress];
    [self.progressView setProgress:fullProgress animated:YES];
}

- (void)analysingOperationFailure:(NSManagedObjectID*)scoreId
{
    self.finishedOperations++;
    
    if (self.finishedOperations == self.totalOperations) {
        [[SleepManager sharedInstance] removeInsomniac:kScoreAnalysingViewControllerSleepIdentifier];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.completionBlock) {
                self.completionBlock(NO);
            }
        }];
    }
}

- (void)analysingOperationSuccess:(NSManagedObjectID*)scoreId
{
    self.finishedOperations++;
    
    if (self.finishedOperations == self.totalOperations) {
        [[SleepManager sharedInstance] removeInsomniac:kScoreAnalysingViewControllerSleepIdentifier];        
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.completionBlock) {
                self.completionBlock(YES);
            }
        }];
    }
}

#pragma mark - Notifications

- (void)cancelAnalysingNotification
{
    [self cancelTapped:nil];
}

@end
