//
//  JumpDataV3.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MeasureDataV3;

@interface JumpDataV3 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * jumpType;
@property (nonatomic, strong) NSNumber * takeRepeats;
@property (nonatomic, strong) MeasureDataV3 * originMeasure;
@property (nonatomic, strong) MeasureDataV3 * destinationMeasure;


@end
