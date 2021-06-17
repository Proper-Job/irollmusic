//
//  SetListEntry.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 08.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Score, Set;

@interface SetListEntry : NSManagedObject {
}

@property (nonatomic, strong) NSNumber * rank;
@property (nonatomic, strong) Score * score;
@property (nonatomic, strong) Set * setList;

+ (NSEntityDescription *)entityDescription;

- (void)decRank;
- (void)incRank;

@end

// coalesce these into one @interface SetListEntry (CoreDataGeneratedAccessors) section
@interface SetListEntry (CoreDataGeneratedAccessors)
@end
