//
//  RecentSetList.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 22.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RecentSetList : NSManagedObject {

}

@property (nonatomic, strong) NSSet* recentSetListEntries;

+ (NSEntityDescription *)entityDescription;
- (NSArray *)orderedRecentSetListEntriesAsc;

@end

// coalesce these into one @interface RecentSetList (CoreDataGeneratedAccessors) section
@interface RecentSetList (CoreDataGeneratedAccessors)
- (void)addRecentSetListEntriesObject:(NSManagedObject *)value;
- (void)removeRecentSetListEntriesObject:(NSManagedObject *)value;
- (void)addRecentSetListEntries:(NSSet *)value;
- (void)removeRecentSetListEntries:(NSSet *)value;

@end
