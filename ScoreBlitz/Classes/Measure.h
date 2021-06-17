//
//  Measure.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 21.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Page;
@class Repeat;
@class Jump;

@interface Measure : NSManagedObject {

}
@property (nonatomic, strong) NSString * coordinateAsString;

@property (nonatomic, strong) NSNumber * bpm;
@property (nonatomic, strong) NSNumber * coda;
@property (nonatomic, strong) NSNumber * fine;
@property (nonatomic, strong) NSNumber * segno;
@property (nonatomic, strong) NSNumber * primaryEnding;
@property (nonatomic, strong) NSNumber * secondaryEnding;
@property (nonatomic, strong) NSNumber * timeDenominator;
@property (nonatomic, strong) NSNumber * timeNumerator;

@property (nonatomic, strong) Repeat * startRepeat;
@property (nonatomic, strong) Repeat * endRepeat;
@property (nonatomic, strong) NSSet* jumpDestinations;
@property (nonatomic, strong) Jump * jumpOrigin;
@property (nonatomic, strong) Page * page;



@property (nonatomic, assign) CGPoint coordinate;

+ (NSEntityDescription *)entityDescription;

- (NSTimeInterval)duration;
- (NSNumber *)xCoordinate;
- (NSNumber *)yCoordinate;
- (BOOL)isJumpOrigin:(APJumpType *)outType;
- (BOOL)hasDetailedOptions;

@end

@interface Measure (CoreDataGeneratedAccessors)
- (void)addJumpDestinationsObject:(NSManagedObject *)value;
- (void)removeJumpDestinationsObject:(NSManagedObject *)value;
- (void)addJumpDestinations:(NSSet *)value;
- (void)removeJumpDestinations:(NSSet *)value;
@end

