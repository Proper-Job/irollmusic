//
//  JumpDataV2.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MeasureDataV2;

@interface JumpDataV2 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * jumpType;
@property (nonatomic, strong) NSNumber * takeRepeats;
@property (nonatomic, strong) MeasureDataV2 * originMeasure;
@property (nonatomic, strong) MeasureDataV2 * destinationMeasure;


@end
