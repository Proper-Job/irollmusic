//
//  TutorialViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CentralViewController;

@interface TutorialViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *tutorials;

@property (nonatomic, weak) CentralViewController *delegate;


- (IBAction)exit;

#define kPreviewViewWidth 540

@end
