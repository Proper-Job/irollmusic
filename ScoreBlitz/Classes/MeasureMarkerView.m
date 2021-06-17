//
//  MeasureMarkerView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 23.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "MeasureMarkerView.h"
#import "Measure.h"
#import "Jump.h"


@implementation MeasureMarkerView

@synthesize measure, firstTouchPoint, numerator, denominator, flowControlLabel,
startRepeat, endRepeat, coda, endings, segno, fine, flashView;
@synthesize startMeasureLabel, startMeasureLabelHostingView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [[Helpers black] colorWithAlphaComponent:.5];
	self.layer.cornerRadius = kMeasureMarkerViewCornerRadius;
    self.flashView.layer.cornerRadius = kMeasureMarkerViewCornerRadius;
    
    self.startMeasureLabelHostingView.layer.cornerRadius = kMeasureMarkerViewCornerRadius;
    self.startMeasureLabelHostingView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.9];
}

- (void)glow
{
    self.flashView.backgroundColor = [Helpers lightPetrol];
    self.flashView.alpha = 1.0;
}

- (void)stopGlow
{
    [UIView animateWithDuration:.2
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         self.flashView.alpha = 0.0;
                     }completion:^(BOOL finished){
                         ;
                     }];
}

- (void)flash
{
    self.flashView.backgroundColor = [Helpers lightPetrol];
    [UIView animateWithDuration:.2
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         self.flashView.alpha = 1.0; 
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:.2
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^(void){
                                              self.flashView.alpha = 0; 
                                          }
                                          completion:NULL];
                     }
     ];
}

- (void)becomeStartMeasure
{
    [self glow];
    self.startMeasureLabelHostingView.hidden = NO;
    self.startMeasureLabel.text = MyLocalizedString(@"buttonChooseStartMeasure", nil);
}

- (void)resignStartMeasure
{
    [self stopGlow];
    self.startMeasureLabelHostingView.hidden = YES;
}

- (void)refreshSymbols
{
    APJumpType jumpType = (nil != self.measure.jumpOrigin) ? [self.measure.jumpOrigin.jumpType intValue] : APJumpTypeNone;
    
    // Repeats
    self.startRepeat.hidden = (nil == self.measure.startRepeat);
    self.endRepeat.hidden = (nil == self.measure.endRepeat);
    
    if ([self.measure.primaryEnding boolValue]) {
		self.endings.image = [UIImage imageNamed:@"first_ending.png"];
	}else if ([self.measure.secondaryEnding boolValue]) {
		self.endings.image = [UIImage imageNamed:@"second_ending.png"];
	}else {
		self.endings.image = nil;
	}
    
	self.fine.hidden = ![self.measure.fine boolValue];
    
    if ([self.measure.coda boolValue] || APJumpTypeGoToCoda == jumpType) {
        self.coda.hidden = NO;
    }else {
        self.coda.hidden = YES;
    }

    BOOL segnoHidden = YES;
    NSString *flowControlText = nil;
    switch (jumpType) {
        case APJumpTypeDaCapo:
        case APJumpTypeDaCapoAlCoda:
        case APJumpTypeDaCapoAlFine:
        case APJumpTypeDaCapoAlSegno:
            flowControlText = MyLocalizedString(@"daCapo", nil);
            break;
        case APJumpTypeDalSegno:
        case APJumpTypeDalSegnoAlCoda:
        case APJumpTypeDalSegnoAlFine:
            segnoHidden = NO;
            break;
    }
    
    if ([self.measure.segno boolValue]) {
        segnoHidden = NO;
    }
    
    self.flowControlLabel.text = flowControlText;
    self.segno.hidden = segnoHidden;

    
    // Meter
    self.numerator.text = [NSString stringWithFormat:@"%d", [self.measure.timeNumerator intValue]];
    self.denominator.text = [NSString stringWithFormat:@"%d", [self.measure.timeDenominator intValue]];

}



@end
