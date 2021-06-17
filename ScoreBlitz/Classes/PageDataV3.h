//
//  PageDataV3.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScoreDataV3;

@interface PageDataV3 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * number;
@property (nonatomic, strong) ScoreDataV3 * score;
@property (nonatomic, strong) NSMutableArray * measures;
@property (nonatomic, strong) NSData * drawAnnotationsData;
@property (nonatomic, strong) NSData * textAnnotationsData;
@property (nonatomic, strong) NSData * signAnnotationsData;

- (NSArray *)measuresSortedByCoordinates;

@end
