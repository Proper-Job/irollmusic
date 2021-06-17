    //
//  TutorialViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import "TutorialViewController.h"
#import "CentralViewController.h"
#import "Tutorial.h"
#import "TutorialCollectionViewCell.h"

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:MyLocalizedString(@"centralViewTutorialsButton", nil)];
    
    [self.navigationItem setRightBarButtonItem:[Helpers doneBarButtonItemWithTarget:self action:@selector(exit)]];
    
    self.view.backgroundColor = [Helpers lightGrey];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TutorialCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TutorialCollectionViewCell"];

    
    self.tutorials = [NSMutableArray array];

    Tutorial *annotationEditorTutorial = [[Tutorial alloc] init];
    annotationEditorTutorial.title = [Helpers localizedTutorialTitleForTutorialType:TutorialTypeAnnotationsEditor];
    annotationEditorTutorial.tutorialDescription = [Helpers localizedTutorialDescriptionForTutorialType:TutorialTypeAnnotationsEditor];
    annotationEditorTutorial.url = [Helpers localizedTutorialMovieUrlForTutorialType:TutorialTypeAnnotationsEditor];
    annotationEditorTutorial.tutorialType = TutorialTypeAnnotationsEditor;
    [self.tutorials addObject:annotationEditorTutorial];
    
    Tutorial *measureEditorTutorial = [[Tutorial alloc] init];
    measureEditorTutorial.title = [Helpers localizedTutorialTitleForTutorialType:TutorialTypeMeasureEditor];
    measureEditorTutorial.tutorialDescription = [Helpers localizedTutorialDescriptionForTutorialType:TutorialTypeMeasureEditor];
    measureEditorTutorial.url = [Helpers localizedTutorialMovieUrlForTutorialType:TutorialTypeMeasureEditor];
    measureEditorTutorial.tutorialType = TutorialTypeMeasureEditor;
    [self.tutorials addObject:measureEditorTutorial];

//    Tutorial *startMeasureEditorTutorial = [[Tutorial alloc] init];
//    startMeasureEditorTutorial.title = [Helpers localizedTutorialTitleForTutorialType:TutorialTypeStartMeasureEditor];
//    startMeasureEditorTutorial.tutorialDescription = [Helpers localizedTutorialDescriptionForTutorialType:TutorialTypeStartMeasureEditor];
//    startMeasureEditorTutorial.url = [Helpers localizedTutorialMovieUrlForTutorialType:TutorialTypeStartMeasureEditor];
//    startMeasureEditorTutorial.tutorialType = TutorialTypeStartMeasureEditor;
//    [self.tutorials addObject:startMeasureEditorTutorial];

    Tutorial *simplePerformanceTutorial = [[Tutorial alloc] init];
    simplePerformanceTutorial.title = [Helpers localizedTutorialTitleForTutorialType:TutorialTypeSimplePerformance];
    simplePerformanceTutorial.tutorialDescription = [Helpers localizedTutorialDescriptionForTutorialType:TutorialTypeSimplePerformance];
    simplePerformanceTutorial.url = [Helpers localizedTutorialMovieUrlForTutorialType:TutorialTypeSimplePerformance];
    simplePerformanceTutorial.tutorialType = TutorialTypeSimplePerformance;
    [self.tutorials addObject:simplePerformanceTutorial];

    Tutorial *advancedPerformanceTutorial = [[Tutorial alloc] init];
    advancedPerformanceTutorial.title = [Helpers localizedTutorialTitleForTutorialType:TutorialTypeAdvancedPerformance];
    advancedPerformanceTutorial.tutorialDescription = [Helpers localizedTutorialDescriptionForTutorialType:TutorialTypeAdvancedPerformance];
    advancedPerformanceTutorial.url = [Helpers localizedTutorialMovieUrlForTutorialType:TutorialTypeAdvancedPerformance];
    advancedPerformanceTutorial.tutorialType = TutorialTypeAdvancedPerformance;
    [self.tutorials addObject:advancedPerformanceTutorial];

    Tutorial *pagingPerformanceTutorial = [[Tutorial alloc] init];
    pagingPerformanceTutorial.title = [Helpers localizedTutorialTitleForTutorialType:TutorialTypePagingPerformance];
    pagingPerformanceTutorial.tutorialDescription = [Helpers localizedTutorialDescriptionForTutorialType:TutorialTypePagingPerformance];
    pagingPerformanceTutorial.url = [Helpers localizedTutorialMovieUrlForTutorialType:TutorialTypePagingPerformance];
    pagingPerformanceTutorial.tutorialType = TutorialTypePagingPerformance;
    [self.tutorials addObject:pagingPerformanceTutorial];

    Tutorial *importTutorial = [[Tutorial alloc] init];
    importTutorial.title = [Helpers localizedTutorialTitleForTutorialType:TutorialTypeImport];
    importTutorial.tutorialDescription = [Helpers localizedTutorialDescriptionForTutorialType:TutorialTypeImport];
    importTutorial.url = [Helpers localizedTutorialMovieUrlForTutorialType:TutorialTypeImport];
    importTutorial.tutorialType = TutorialTypeImport;
    [self.tutorials addObject:importTutorial];

}

#pragma mark -
#pragma mark Button Actions


- (IBAction)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.tutorials count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Tutorial *tutorial = [self.tutorials objectAtIndex:indexPath.row];
    
    TutorialCollectionViewCell *tutorialCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TutorialCollectionViewCell" forIndexPath:indexPath];
    [tutorialCollectionViewCell setupWithTutorial:tutorial];
    
    return tutorialCollectionViewCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Tutorial *tutorial = [self.tutorials objectAtIndex:indexPath.row];

    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate playMovieWithUrl:tutorial.url];
    }];
}


@end
