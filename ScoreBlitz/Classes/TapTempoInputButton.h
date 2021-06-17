//
//  TapTempoInputButton.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TapTempoInputButton : UIButton

@property (nonatomic, copy) void (^didSelectBpmBlock)(NSNumber *bpm);

- (IBAction)tap;
@end
