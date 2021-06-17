//
//  RecentSetListEntry.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Set;

@interface RecentSetListEntry : NSManagedObject {

}

@property (nonatomic, strong) NSNumber * rank;
@property (nonatomic, strong) NSManagedObject * recentSetList;
@property (nonatomic, strong) Set * setList;

+ (NSEntityDescription *)entityDescription;
- (void)decRank;
- (void)incRank;
@end

// coalesce these into one @interface RecentSetListEntry (CoreDataGeneratedAccessors) section
@interface RecentSetListEntry (CoreDataGeneratedAccessors)
@end
