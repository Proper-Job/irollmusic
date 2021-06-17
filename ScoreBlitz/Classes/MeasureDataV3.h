//
//  MeasureDataV3.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageDataV3, RepeatDataV3, JumpDataV3;

@interface MeasureDataV3 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSString * coordinateAsString;

@property (nonatomic, strong) NSNumber * bpm;
@property (nonatomic, strong) NSNumber * coda;
@property (nonatomic, strong) NSNumber * fine;
@property (nonatomic, strong) NSNumber * segno;
@property (nonatomic, strong) NSNumber * primaryEnding;
@property (nonatomic, strong) NSNumber * secondaryEnding;
@property (nonatomic, strong) NSNumber * timeDenominator;
@property (nonatomic, strong) NSNumber * timeNumerator;

@property (nonatomic, strong) RepeatDataV3 * startRepeat;
@property (nonatomic, strong) RepeatDataV3 * endRepeat;
@property (nonatomic, strong) NSMutableSet * jumpDestinations;
@property (nonatomic, strong) JumpDataV3 * jumpOrigin;
@property (nonatomic, strong) PageDataV3 * page;

- (NSNumber *)xCoordinate;
- (NSNumber *)yCoordinate;

@end
