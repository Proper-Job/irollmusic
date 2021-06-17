//
//  TutorialCollectionViewCell.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.05.14.
//
//

#import <UIKit/UIKit.h>

@class Tutorial;

@interface TutorialCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel, *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;

- (void)setupWithTutorial:(Tutorial*)tutorial;

@end
