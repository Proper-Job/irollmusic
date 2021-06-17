//
//  PageDataV2.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ScoreDataV2;

@interface PageDataV2 : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) NSNumber * number;
@property (nonatomic, strong) ScoreDataV2 * score;
@property (nonatomic, strong) NSMutableArray * measures;
@property (nonatomic, strong) NSData * drawAnnotationsData;
@property (nonatomic, strong) NSData * textAnnotationsData;

- (NSArray *)measuresSortedByCoordinates;

@end
