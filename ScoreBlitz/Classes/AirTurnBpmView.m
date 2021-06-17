//
//  AirTurnBpmView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 13.12.13.
//
//

#import "AirTurnBpmView.h"

@implementation AirTurnBpmView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 6;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
}

@end
