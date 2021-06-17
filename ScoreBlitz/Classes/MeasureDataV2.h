//
//  MeasureDataV2.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageDataV2, RepeatDataV2, JumpDataV2;

@interface MeasureDataV2 : NSObject <NSCoding> {
    
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

@property (nonatomic, strong) RepeatDataV2 * startRepeat;
@property (nonatomic, strong) RepeatDataV2 * endRepeat;
@property (nonatomic, strong) NSMutableSet * jumpDestinations;
@property (nonatomic, strong) JumpDataV2 * jumpOrigin;
@property (nonatomic, strong) PageDataV2 * page;

- (NSNumber *)xCoordinate;
- (NSNumber *)yCoordinate;

@end
