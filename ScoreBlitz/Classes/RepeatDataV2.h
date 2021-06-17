//
//  RepeatDataV2.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MeasureDataV2;

@interface RepeatDataV2 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * numberOfRepeats;
@property (nonatomic, strong) MeasureDataV2 * endMeasure;
@property (nonatomic, strong) MeasureDataV2 * startMeasure;

@end
