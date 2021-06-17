//
//  PageNumberIndicatorView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PageNumberIndicatorView : UIView {
    
}

@property (nonatomic, strong) IBOutlet UIImageView *topImageView, *bottomImageView;
@property (nonatomic, strong) IBOutlet UILabel *pageNumberLabel;
@property (nonatomic, strong) IBOutlet UIView *pageNumberBackgroundView;
@property (nonatomic, assign) TapZonePagePosition tapZonePagePosition;

- (void)showPageNumber:(NSInteger)number
                inView:(UIView *)theSuperView 
        positionInView:(PageNumberIndicatorPosition)positionInView
   tapZonePagePosition:(TapZonePagePosition)tapZonePosition;


#define kFadeOutDuration 2.0

@end
