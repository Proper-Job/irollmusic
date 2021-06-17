//
//  Measure.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 21.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "Measure.h"
#import "Page.h"
#import "ScoreBlitzAppDelegate.h"
#import "Jump.h"
#import "Score.h"

@implementation Measure

@dynamic coordinateAsString;

@dynamic bpm;
@dynamic coda;
@dynamic fine;
@dynamic segno;
@dynamic primaryEnding;
@dynamic secondaryEnding;
@dynamic timeDenominator;
@dynamic timeNumerator;
@dynamic startRepeat;
@dynamic endRepeat;
@dynamic jumpDestinations;
@dynamic jumpOrigin;
@dynamic page;

@synthesize coordinate;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"Measure" inManagedObjectContext:context];
}

- (void)awakeFromInsert 
{
    [super awakeFromInsert];
    
    self.bpm = [NSNumber numberWithInt:0];
    self.coda = [NSNumber numberWithBool:NO];
    self.coordinateAsString = nil;
    self.fine = [NSNumber numberWithBool:NO];
    self.primaryEnding = [NSNumber numberWithBool:NO];
    self.secondaryEnding = [NSNumber numberWithBool:NO];
    self.segno = [NSNumber numberWithBool:NO];
    self.timeNumerator = [NSNumber numberWithInt:4];
    self.timeDenominator = [NSNumber numberWithInt:4];
}

- (CGPoint)coordinate
{
	return CGPointFromString(self.coordinateAsString);
}

- (void)setCoordinate:(CGPoint)newCoordinate
{
	self.coordinateAsString = NSStringFromCGPoint(newCoordinate);
}

- (NSTimeInterval)duration
{
    Score *myScore = self.page.score;
    double metronomeNoteValue = [Helpers doubleValueForNoteValue:myScore.metronomeNoteValue];
    double myNoteValue = [Helpers doubleValueForTimeDenominator:self.timeDenominator];
    double commonDenominatorFactor = myNoteValue / metronomeNoteValue;
    double bpm = MAX([myScore.metronomeBpm doubleValue] + [self.bpm doubleValue], 1.0);
    double duration = (60.0 / bpm) * ([self.timeNumerator doubleValue] * commonDenominatorFactor);
    
    //NSLog(@"measure duration: %f", duration);
    
    return duration;
}


- (NSNumber *)xCoordinate
{
    CGPoint point = CGPointFromString(self.coordinateAsString);
    return [NSNumber numberWithFloat:point.x];
}

- (NSNumber *)yCoordinate
{
    CGPoint point = CGPointFromString(self.coordinateAsString);
    return [NSNumber numberWithFloat:point.y];
}


- (BOOL)isJumpOrigin:(APJumpType *)outType
{
    if (nil != self.jumpOrigin) {
        if (NULL != outType) {
            *outType = [self.jumpOrigin.jumpType intValue];
        }
        return YES;
    }else {
        if (NULL != outType) {
            *outType = APJumpTypeNone;
        }
        return NO;
    }
}

- (BOOL)hasDetailedOptions
{
    if (nil != self.jumpOrigin || [self.fine boolValue]  ||
        [self.coda boolValue]  || [self.segno boolValue])
    {
        return YES;
    }
    return  NO;
}

@end
