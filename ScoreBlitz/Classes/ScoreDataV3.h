//
//  ScoreDataV3.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreDataV3 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSString * artist;
@property (nonatomic, strong) NSString * composer;
@property (nonatomic, strong) NSString * genre;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * playTime;
@property (nonatomic, strong) NSMutableArray* pages;
@property (nonatomic, strong) NSString * sha1Hash;
@property (nonatomic, strong) NSNumber * metronomeBpm;
@property (nonatomic, strong) NSNumber * scrollSpeed;
@property (nonatomic, strong) NSNumber * automaticPlayTimeCalculation;
@property (nonatomic, strong) NSNumber * preferredPerformanceMode;
@property (nonatomic, strong) NSString * metronomeNoteValue;
@property (nonatomic, strong) NSNumber * rotationAngle;

- (NSArray *)measuresSortedByCoordinates;

@end
