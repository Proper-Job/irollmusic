//
//  ScoreRotationViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import "ScoreRotationViewController.h"
#import "Score.h"
#import "ScoreRotationOperation.h"
#import "ScoreAnalysingOperation.h"
#import "SleepManager.h"

#define kScoreRotationViewControllerSleepIdentifier @"ScoreRotationViewController"

@interface ScoreRotationViewController ()

@end

@implementation ScoreRotationViewController

- (id)initWithScore:(Score*)score
{
    if (self = [super init]) {
        self.score = score;
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = MyLocalizedString(@"ScoreRotationTitleMessage", nil);
    self.progressLabel.text = @"0 %";
    
    self.progressView.progressTintColor = [Helpers petrol];
    self.progressView.progress = 0;
    
    [self.cancelButton setTitle:MyLocalizedString(@"buttonCancel", nil) forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [Helpers petrol];
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor];
    
    if (self.score) {
        [[SleepManager sharedInstance] addInsomniac:kScoreRotationViewControllerSleepIdentifier];

        ScoreRotationOperation *scoreRotationOperation = [[ScoreRotationOperation alloc] initWithObjectID:self.score.objectID];
        [scoreRotationOperation setCompletionBlockWithSuccess:^(NSManagedObjectID *scoreId) {
            [[SleepManager sharedInstance] removeInsomniac:kScoreRotationViewControllerSleepIdentifier];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(NSManagedObjectID *scoreId) {
            [[SleepManager sharedInstance] removeInsomniac:kScoreRotationViewControllerSleepIdentifier];
            self.titleLabel.text = MyLocalizedString(@"ScoreRotationFailedMessage", nil);
            [self.cancelButton setTitle:MyLocalizedString(@"buttonDone", nil) forState:UIControlStateNormal];
        }];
        [scoreRotationOperation setProgressBlock:^(NSString *scoreName, CGFloat progress) {
            int intProgress = (int)roundf(progress * 100);
            self.progressLabel.text = [NSString stringWithFormat:@"%d %%", intProgress];
            [self.progressView setProgress:progress animated:YES];
            
        }];
        [self.operationQueue addOperation:scoreRotationOperation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelTapped:(id)sender
{
    [[SleepManager sharedInstance] removeInsomniac:kScoreRotationViewControllerSleepIdentifier];
    [self.operationQueue cancelAllOperations];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
