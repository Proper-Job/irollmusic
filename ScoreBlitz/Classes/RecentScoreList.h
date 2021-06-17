//
//  RecentScoreList.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RecentScoreList : NSManagedObject {

}

@property (nonatomic, strong) NSSet* recentScoreListEntries;

+ (NSEntityDescription *)entityDescription;
- (NSArray *)orderedRecentScoreListEntriesAsc;

@end



// coalesce these into one @interface RecentScoreList (CoreDataGeneratedAccessors) section
@interface RecentScoreList (CoreDataGeneratedAccessors)
- (void)addRecentScoreListEntriesObject:(NSManagedObject *)value;
- (void)removeRecentScoreListEntriesObject:(NSManagedObject *)value;
- (void)addRecentScoreListEntries:(NSSet *)value;
- (void)removeRecentScoreListEntries:(NSSet *)value;

@end
