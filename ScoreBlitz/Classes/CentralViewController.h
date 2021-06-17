//
//  CentralViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CentralViewController : UIViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *scoreCollectionView, *setCollectionView;
@property (nonatomic, strong) IBOutlet UILabel *scoresLabel, *setsLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *libraryButton, *tutorialsButton, *settingsButton;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;

@property (nonatomic, strong) NSFetchedResultsController *scoreFetchedResultsController, *setFetchedResultsController;
@property (nonatomic, strong) UIView *blockingView;

- (void)languageChanged;
- (void)didFinischCopyingDefaultData;

// Button Actions
- (IBAction)showLibrary;
- (IBAction)showTutorials;
- (IBAction)showSettings;

- (void)playMovieWithUrl:(NSURL *)url;

@end
