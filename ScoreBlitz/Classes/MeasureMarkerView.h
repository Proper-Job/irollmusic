//
//  MeasureMarkerView.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 23.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Measure;

@interface MeasureMarkerView : UIView {
    
}

@property (nonatomic, strong) Measure *measure;
@property (nonatomic, assign) CGPoint firstTouchPoint;
@property (nonatomic, strong) IBOutlet UILabel *numerator, *denominator, *flowControlLabel, *fine, *startMeasureLabel;
@property (nonatomic, strong) IBOutlet UIImageView *startRepeat, *endRepeat, *coda, *endings, *segno;
@property (nonatomic, strong) IBOutlet UIView *flashView, *startMeasureLabelHostingView;

- (void)glow;
- (void)stopGlow;
- (void)flash;
- (void)refreshSymbols;
- (void)becomeStartMeasure;
- (void)resignStartMeasure;
@end
