//
//  scoreDataV1.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScoreDataV1 : NSObject <NSCoding> {
    
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

- (NSArray *)measuresSortedByCoordinates;

@end
