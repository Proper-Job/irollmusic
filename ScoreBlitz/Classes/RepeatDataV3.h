//
//  RepeatDataV3.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MeasureDataV3;

@interface RepeatDataV3 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * numberOfRepeats;
@property (nonatomic, strong) MeasureDataV3 * endMeasure;
@property (nonatomic, strong) MeasureDataV3 * startMeasure;

@end
