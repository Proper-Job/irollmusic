//
//  repeatDataV1.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MeasureDataV1;

@interface RepeatDataV1 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * numberOfRepeats;
@property (nonatomic, strong) MeasureDataV1 * endMeasure;
@property (nonatomic, strong) MeasureDataV1 * startMeasure;

@end
