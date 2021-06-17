//
//  TutorialCollectionViewCell.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.05.14.
//
//

#import "TutorialCollectionViewCell.h"
#import "Tutorial.h"

@implementation TutorialCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupWithTutorial:(Tutorial*)tutorial
{
    self.titleLabel.text = tutorial.title;
    self.descriptionLabel.text = tutorial.tutorialDescription;
    self.previewImageView.image = [Helpers splashImageForTutorialType:tutorial.tutorialType];
}


@end
