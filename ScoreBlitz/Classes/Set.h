//
//  Set.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 03.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Set : NSManagedObject {

}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet* setListEntries;

+ (NSEntityDescription *)entityDescription;
- (NSArray *)orderedSetListEntriesAsc;
- (NSInteger)playTime;
- (NSString *)playTimeString;
- (NSArray*)unAnalyzedScores;

@end

// coalesce these into one @interface Set (CoreDataGeneratedAccessors) section
@interface Set (CoreDataGeneratedAccessors)
- (void)addSetListEntriesObject:(NSManagedObject *)value;
- (void)removeSetListEntriesObject:(NSManagedObject *)value;
- (void)addSetListEntries:(NSSet *)value;
- (void)removeSetListEntries:(NSSet *)value;

@end
