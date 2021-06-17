//
//  jumpDataV1.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MeasureDataV1;

@interface JumpDataV1 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * jumpType;
@property (nonatomic, strong) NSNumber * takeRepeats;
@property (nonatomic, strong) MeasureDataV1 * originMeasure;
@property (nonatomic, strong) MeasureDataV1 * destinationMeasure;


@end
