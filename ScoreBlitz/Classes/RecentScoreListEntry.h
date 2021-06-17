//
//  RecentScoreListEntry.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Score;

@interface RecentScoreListEntry : NSManagedObject {

}

@property (nonatomic, strong) NSNumber * rank;
@property (nonatomic, strong) NSManagedObject * recentScoreList;
@property (nonatomic, strong) Score * score;

+ (NSEntityDescription *)entityDescription;
- (void)decRank;
- (void)incRank;

@end


// coalesce these into one @interface RecentScoreListEntry (CoreDataGeneratedAccessors) section
@interface RecentScoreListEntry (CoreDataGeneratedAccessors)
@end
