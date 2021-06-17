//
//  pageDataV1.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScoreDataV1;

@interface PageDataV1 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * number;
@property (nonatomic, strong) ScoreDataV1 * score;
@property (nonatomic, strong) NSMutableArray * measures;
@property (nonatomic, strong) NSData * drawAnnotationsData;
@property (nonatomic, strong) NSData * textAnnotationsData;

- (NSArray *)measuresSortedByCoordinates;

@end
