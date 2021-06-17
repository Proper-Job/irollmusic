//
//  measureDataV1.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageDataV1, RepeatDataV1, JumpDataV1;

@interface MeasureDataV1 : NSObject <NSCoding> {
    
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

@property (nonatomic, strong) RepeatDataV1 * startRepeat;
@property (nonatomic, strong) RepeatDataV1 * endRepeat;
@property (nonatomic, strong) NSMutableSet * jumpDestinations;
@property (nonatomic, strong) JumpDataV1 * jumpOrigin;
@property (nonatomic, strong) PageDataV1 * page;

- (NSNumber *)xCoordinate;
- (NSNumber *)yCoordinate;

@end
