//
//  ImportExportManager.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImportExportManager.h"
#import "ScoreBlitzAppDelegate.h"
#import "Score.h"
#import "Page.h"
#import "Measure.h"
#import "Jump.h"
#import "Repeat.h"

#import "ScoreDataV1.h"
#import "PageDataV1.h"
#import "MeasureDataV1.h"
#import "JumpDataV1.h"
#import "RepeatDataV1.h"

#import "ScoreDataV2.h"
#import "PageDataV2.h"
#import "MeasureDataV2.h"
#import "JumpDataV2.h"
#import "RepeatDataV2.h"

#import "ScoreDataV3.h"
#import "PageDataV3.h"
#import "MeasureDataV3.h"
#import "JumpDataV3.h"
#import "RepeatDataV3.h"


@implementation ImportExportManager

@synthesize _context, _data, _score;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
	self = [super init];
	if (self != nil) {
        _context = managedObjectContext;
	}
	return self;
}

#pragma mark -
#pragma mark Data Version 1

- (Score*)importDataV1:(NSData*)data
{
    self._data = data;
    
    ScoreDataV1 *scoreImport = [NSKeyedUnarchiver unarchiveObjectWithData:_data];
    
    Score *newScore = (Score *) [[NSManagedObject alloc] initWithEntity:[Score entityDescription]
                                         insertIntoManagedObjectContext:_context];
    newScore.name = scoreImport.name;
    newScore.composer = scoreImport.composer;
    newScore.genre = scoreImport.genre;
    newScore.artist = scoreImport.artist;
    newScore.playTime = scoreImport.playTime;
    newScore.metronomeBpm = scoreImport.metronomeBpm;
    newScore.scrollSpeed = scoreImport.scrollSpeed;
    newScore.automaticPlayTimeCalculation = scoreImport.automaticPlayTimeCalculation;
    newScore.preferredPerformanceMode = scoreImport.preferredPerformanceMode;
    
    for (PageDataV1 *pageData in scoreImport.pages) {
        Page *newPage = (Page *) [[NSManagedObject alloc] initWithEntity:[Page entityDescription]
									   insertIntoManagedObjectContext:_context];
        newPage.number = pageData.number;
        newPage.drawAnnotationsData = pageData.drawAnnotationsData;
        newPage.textAnnotationsData = pageData.textAnnotationsData;
        newPage.score = newScore;
        
        for (MeasureDataV1 *measureData in pageData.measures) {
            Measure *newMeasure = (Measure *) [[NSManagedObject alloc] initWithEntity:[Measure entityDescription]
                                              insertIntoManagedObjectContext:_context];
            newMeasure.coordinateAsString = measureData.coordinateAsString;
            newMeasure.bpm = measureData.bpm;
            newMeasure.coda = measureData.coda;
            newMeasure.fine = measureData.fine;
            newMeasure.segno = measureData.segno;
            newMeasure.primaryEnding = measureData.primaryEnding;
            newMeasure.secondaryEnding = measureData.secondaryEnding;
            newMeasure.timeDenominator = measureData.timeDenominator;
            newMeasure.timeNumerator = measureData.timeNumerator;
            newMeasure.page = newPage;
        }
    }
    
    NSArray *measuresInDB = [newScore measuresSortedByCoordinates];
    NSArray *measureDataObjects = [scoreImport measuresSortedByCoordinates];
    
    for (MeasureDataV1 *measureData in measureDataObjects) {
        NSInteger index = [measureDataObjects indexOfObject:measureData];
        Measure *measure = [measuresInDB objectAtIndex:index];
        
        if (nil != measureData.startRepeat && nil != measureData.startRepeat.endMeasure) {
            if (nil == measure.startRepeat) {
                Repeat *newRepeat = (Repeat *) [[NSManagedObject alloc] initWithEntity:[Repeat entityDescription] 
                                                        insertIntoManagedObjectContext:_context];
                newRepeat.numberOfRepeats = measureData.startRepeat.numberOfRepeats;
                newRepeat.startMeasure = measure;
                newRepeat.endMeasure = [measuresInDB objectAtIndex:[measureDataObjects indexOfObject:measureData.startRepeat.endMeasure]];
            }else {
#ifdef DEBUG
                NSLog(@"This should never happen.  Trying to restore duplicate start repeat during measure import");
#endif           
            }
        }
        
        if (nil != measureData.jumpOrigin && nil != measureData.jumpOrigin.destinationMeasure) {        
            if (nil == measure.jumpOrigin) {
                Jump *newJump = (Jump *) [[NSManagedObject alloc] initWithEntity:[Jump entityDescription]
                                                  insertIntoManagedObjectContext:_context];
                newJump.jumpType = measureData.jumpOrigin.jumpType;
                newJump.takeRepeats = measureData.jumpOrigin.takeRepeats;
                newJump.originMeasure = measure;
                newJump.destinationMeasure = [measuresInDB objectAtIndex:[measureDataObjects indexOfObject:measureData.jumpOrigin.destinationMeasure]];
            }else {
#ifdef DEBUG
                NSLog(@"This should never happen.  Trying to restore duplicate start jump origin during measure import");
#endif        
            }
        }
    }
#ifdef DEBUG        
    NSLog(@"ImportExportManager: imported score %@", newScore);
#endif      
    return newScore;
}

- (NSData*)exportScoreV1:(Score*)score withAnnotations:(BOOL)withAnnotations
{
    self._score = score;
    
    ScoreDataV1 *scoreExport = [[ScoreDataV1 alloc] init];
    scoreExport.name = _score.name;
    scoreExport.composer = _score.composer;
    scoreExport.genre = _score.genre;
    scoreExport.artist = _score.artist;
    scoreExport.playTime = _score.playTime;
    scoreExport.pages = [NSMutableArray array];
    scoreExport.metronomeBpm = _score.metronomeBpm;
    scoreExport.scrollSpeed = _score.scrollSpeed;
    scoreExport.automaticPlayTimeCalculation = _score.automaticPlayTimeCalculation;
    scoreExport.preferredPerformanceMode = _score.preferredPerformanceMode;
    
    NSArray *pages = [_score orderedPagesAsc];
    
    for (Page *page in pages) {
        PageDataV1 *pageExport = [[PageDataV1 alloc] init];
        [scoreExport.pages addObject:pageExport];
        pageExport.number = page.number;
        pageExport.score = scoreExport;

        if (withAnnotations) {
            pageExport.drawAnnotationsData = page.drawAnnotationsData;
            pageExport.textAnnotationsData = page.textAnnotationsData;
        } else {
            pageExport.drawAnnotationsData = nil;
            pageExport.textAnnotationsData = nil;
        }
        
        pageExport.measures = [NSMutableArray array];
        
        NSArray *measures = [page measuresSortedByCoordinates];
        
        for (Measure *measure in measures) {
            MeasureDataV1 *measureExport = [[MeasureDataV1 alloc] init];
            [pageExport.measures addObject:measureExport];
            measureExport.coordinateAsString = measure.coordinateAsString;
            measureExport.bpm = measure.bpm;
            measureExport.coda = measure.coda;
            measureExport.fine = measure.fine;
            measureExport.segno = measure.segno;
            measureExport.primaryEnding = measure.primaryEnding;
            measureExport.secondaryEnding = measure.secondaryEnding;
            measureExport.timeDenominator = measure.timeDenominator;
            measureExport.timeNumerator = measure.timeNumerator;
            measureExport.jumpDestinations = [NSMutableSet set];
        }
    }
    
    NSArray *measuresOfScore = [_score measuresSortedByCoordinates];
    NSArray *measureDataObjects = [scoreExport measuresSortedByCoordinates];
    
    for (Measure *measure in measuresOfScore) {
        NSInteger indexOfMeasure = [measuresOfScore indexOfObject:measure];
        MeasureDataV1 *cachedMeasureExport = [measureDataObjects objectAtIndex:indexOfMeasure];
        
        if (nil != measure.startRepeat && nil != measure.startRepeat.endMeasure) {
            RepeatDataV1 *repeatExport = [[RepeatDataV1 alloc] init];
            repeatExport.numberOfRepeats = measure.startRepeat.numberOfRepeats;
            repeatExport.startMeasure = cachedMeasureExport;
            repeatExport.endMeasure = [measureDataObjects objectAtIndex:[measuresOfScore indexOfObject:measure.startRepeat.endMeasure]];
            cachedMeasureExport.startRepeat = repeatExport;
        }
        
        if (nil != measure.jumpOrigin && nil != measure.jumpOrigin.destinationMeasure) {
            JumpDataV1 *jumpExport = [[JumpDataV1 alloc] init];
            jumpExport.jumpType = measure.jumpOrigin.jumpType;
            jumpExport.takeRepeats = measure.jumpOrigin.takeRepeats;
            jumpExport.originMeasure = cachedMeasureExport;
            jumpExport.destinationMeasure = [measureDataObjects objectAtIndex:[measuresOfScore indexOfObject:measure.jumpOrigin.destinationMeasure]];
            cachedMeasureExport.jumpOrigin = jumpExport;
        }
    }
    
    return [NSKeyedArchiver archivedDataWithRootObject:scoreExport];
}

#pragma mark -
#pragma mark Data Version 2


- (Score*)importDataV2:(NSData*)data
{
    self._data = data;
    
    ScoreDataV2 *scoreImport = [NSKeyedUnarchiver unarchiveObjectWithData:_data];
    
    Score *newScore = (Score *) [[NSManagedObject alloc] initWithEntity:[Score entityDescription]
                                         insertIntoManagedObjectContext:_context];
    newScore.name = scoreImport.name;
    newScore.composer = scoreImport.composer;
    newScore.genre = scoreImport.genre;
    newScore.artist = scoreImport.artist;
    newScore.playTime = scoreImport.playTime;
    newScore.metronomeBpm = scoreImport.metronomeBpm;
    newScore.scrollSpeed = scoreImport.scrollSpeed;
    newScore.automaticPlayTimeCalculation = scoreImport.automaticPlayTimeCalculation;
    newScore.preferredPerformanceMode = scoreImport.preferredPerformanceMode;
    newScore.metronomeNoteValue = scoreImport.metronomeNoteValue;
    newScore.rotationAngle = scoreImport.rotationAngle;
    
    for (PageDataV2 *pageData in scoreImport.pages) {
        Page *newPage = (Page *) [[NSManagedObject alloc] initWithEntity:[Page entityDescription]
                                          insertIntoManagedObjectContext:_context];
        newPage.number = pageData.number;
        newPage.drawAnnotationsData = pageData.drawAnnotationsData;
        newPage.textAnnotationsData = pageData.textAnnotationsData;
        newPage.score = newScore;
        
        for (MeasureDataV2 *measureData in pageData.measures) {
            Measure *newMeasure = (Measure *) [[NSManagedObject alloc] initWithEntity:[Measure entityDescription]
                                                       insertIntoManagedObjectContext:_context];
            newMeasure.coordinateAsString = measureData.coordinateAsString;
            newMeasure.bpm = measureData.bpm;
            newMeasure.coda = measureData.coda;
            newMeasure.fine = measureData.fine;
            newMeasure.segno = measureData.segno;
            newMeasure.primaryEnding = measureData.primaryEnding;
            newMeasure.secondaryEnding = measureData.secondaryEnding;
            newMeasure.timeDenominator = measureData.timeDenominator;
            newMeasure.timeNumerator = measureData.timeNumerator;
            newMeasure.page = newPage;
        }
    }
    
    NSArray *measuresInDB = [newScore measuresSortedByCoordinates];
    NSArray *measureDataObjects = [scoreImport measuresSortedByCoordinates];
    
    for (MeasureDataV2 *measureData in measureDataObjects) {
        NSInteger index = [measureDataObjects indexOfObject:measureData];
        Measure *measure = [measuresInDB objectAtIndex:index];
        
        if (nil != measureData.startRepeat && nil != measureData.startRepeat.endMeasure) {
            if (nil == measure.startRepeat) {
                Repeat *newRepeat = (Repeat *) [[NSManagedObject alloc] initWithEntity:[Repeat entityDescription] 
                                                        insertIntoManagedObjectContext:_context];
                newRepeat.numberOfRepeats = measureData.startRepeat.numberOfRepeats;
                newRepeat.startMeasure = measure;
                newRepeat.endMeasure = [measuresInDB objectAtIndex:[measureDataObjects indexOfObject:measureData.startRepeat.endMeasure]];
            }else {
#ifdef DEBUG
                NSLog(@"This should never happen.  Trying to restore duplicate start repeat during measure import");
#endif           
            }
        }
        
        if (nil != measureData.jumpOrigin && nil != measureData.jumpOrigin.destinationMeasure) {        
            if (nil == measure.jumpOrigin) {
                Jump *newJump = (Jump *) [[NSManagedObject alloc] initWithEntity:[Jump entityDescription]
                                                  insertIntoManagedObjectContext:_context];
                newJump.jumpType = measureData.jumpOrigin.jumpType;
                newJump.takeRepeats = measureData.jumpOrigin.takeRepeats;
                newJump.originMeasure = measure;
                newJump.destinationMeasure = [measuresInDB objectAtIndex:[measureDataObjects indexOfObject:measureData.jumpOrigin.destinationMeasure]];
            }else {
#ifdef DEBUG
                NSLog(@"This should never happen.  Trying to restore duplicate start jump origin during measure import");
#endif        
            }
        }
    }
#ifdef DEBUG        
    NSLog(@"ImportExportManager: imported score %@", newScore);
#endif      
    return newScore;
}

- (NSData*)exportScoreV2:(Score*)score withAnnotations:(BOOL)withAnnotations
{
    self._score = score;
    
    ScoreDataV2 *scoreExport = [[ScoreDataV2 alloc] init];
    scoreExport.name = _score.name;
    scoreExport.composer = _score.composer;
    scoreExport.genre = _score.genre;
    scoreExport.artist = _score.artist;
    scoreExport.playTime = _score.playTime;
    scoreExport.pages = [NSMutableArray array];
    scoreExport.metronomeBpm = _score.metronomeBpm;
    scoreExport.scrollSpeed = _score.scrollSpeed;
    scoreExport.automaticPlayTimeCalculation = _score.automaticPlayTimeCalculation;
    scoreExport.preferredPerformanceMode = _score.preferredPerformanceMode;
    scoreExport.metronomeNoteValue = _score.metronomeNoteValue;
    scoreExport.rotationAngle = _score.rotationAngle;
    
    NSArray *pages = [_score orderedPagesAsc];
    
    for (Page *page in pages) {
        PageDataV2 *pageExport = [[PageDataV2 alloc] init];
        [scoreExport.pages addObject:pageExport];
        pageExport.number = page.number;
        pageExport.score = scoreExport;
        
        if (withAnnotations) {
            pageExport.drawAnnotationsData = page.drawAnnotationsData;
            pageExport.textAnnotationsData = page.textAnnotationsData;
        } else {
            pageExport.drawAnnotationsData = nil;
            pageExport.textAnnotationsData = nil;
        }
        
        pageExport.measures = [NSMutableArray array];
        
        NSArray *measures = [page measuresSortedByCoordinates];
        
        for (Measure *measure in measures) {
            MeasureDataV2 *measureExport = [[MeasureDataV2 alloc] init];
            [pageExport.measures addObject:measureExport];
            measureExport.coordinateAsString = measure.coordinateAsString;
            measureExport.bpm = measure.bpm;
            measureExport.coda = measure.coda;
            measureExport.fine = measure.fine;
            measureExport.segno = measure.segno;
            measureExport.primaryEnding = measure.primaryEnding;
            measureExport.secondaryEnding = measure.secondaryEnding;
            measureExport.timeDenominator = measure.timeDenominator;
            measureExport.timeNumerator = measure.timeNumerator;
            measureExport.jumpDestinations = [NSMutableSet set];
        }
    }
    
    NSArray *measuresOfScore = [_score measuresSortedByCoordinates];
    NSArray *measureDataObjects = [scoreExport measuresSortedByCoordinates];
    
    for (Measure *measure in measuresOfScore) {
        NSInteger indexOfMeasure = [measuresOfScore indexOfObject:measure];
        MeasureDataV2 *cachedMeasureExport = [measureDataObjects objectAtIndex:indexOfMeasure];
        
        if (nil != measure.startRepeat && nil != measure.startRepeat.endMeasure) {
            RepeatDataV2 *repeatExport = [[RepeatDataV2 alloc] init];
            repeatExport.numberOfRepeats = measure.startRepeat.numberOfRepeats;
            repeatExport.startMeasure = cachedMeasureExport;
            repeatExport.endMeasure = [measureDataObjects objectAtIndex:[measuresOfScore indexOfObject:measure.startRepeat.endMeasure]];
            cachedMeasureExport.startRepeat = repeatExport;
        }
        
        if (nil != measure.jumpOrigin && nil != measure.jumpOrigin.destinationMeasure) {
            JumpDataV2 *jumpExport = [[JumpDataV2 alloc] init];
            jumpExport.jumpType = measure.jumpOrigin.jumpType;
            jumpExport.takeRepeats = measure.jumpOrigin.takeRepeats;
            jumpExport.originMeasure = cachedMeasureExport;
            jumpExport.destinationMeasure = [measureDataObjects objectAtIndex:[measuresOfScore indexOfObject:measure.jumpOrigin.destinationMeasure]];
            cachedMeasureExport.jumpOrigin = jumpExport;
        }
    }
    
    return [NSKeyedArchiver archivedDataWithRootObject:scoreExport];
}

#pragma mark -
#pragma mark Data Version 3

- (Score*)importDataV3:(NSData*)data
{
    self._data = data;
    
    ScoreDataV3 *scoreImport = [NSKeyedUnarchiver unarchiveObjectWithData:_data];
    
    Score *newScore = (Score *) [[NSManagedObject alloc] initWithEntity:[Score entityDescription]
                                         insertIntoManagedObjectContext:_context];
    newScore.name = scoreImport.name;
    newScore.composer = scoreImport.composer;
    newScore.genre = scoreImport.genre;
    newScore.artist = scoreImport.artist;
    newScore.playTime = scoreImport.playTime;
    newScore.metronomeBpm = scoreImport.metronomeBpm;
    newScore.scrollSpeed = scoreImport.scrollSpeed;
    newScore.automaticPlayTimeCalculation = scoreImport.automaticPlayTimeCalculation;
    newScore.preferredPerformanceMode = scoreImport.preferredPerformanceMode;
    newScore.metronomeNoteValue = scoreImport.metronomeNoteValue;
    newScore.rotationAngle = scoreImport.rotationAngle;
    
    for (PageDataV3 *pageData in scoreImport.pages) {
        Page *newPage = (Page *) [[NSManagedObject alloc] initWithEntity:[Page entityDescription]
                                          insertIntoManagedObjectContext:_context];
        newPage.number = pageData.number;
        newPage.drawAnnotationsData = pageData.drawAnnotationsData;
        newPage.textAnnotationsData = pageData.textAnnotationsData;
        newPage.signAnnotationsData = pageData.signAnnotationsData;
        newPage.score = newScore;
        
        for (MeasureDataV3 *measureData in pageData.measures) {
            Measure *newMeasure = (Measure *) [[NSManagedObject alloc] initWithEntity:[Measure entityDescription]
                                                       insertIntoManagedObjectContext:_context];
            newMeasure.coordinateAsString = measureData.coordinateAsString;
            newMeasure.bpm = measureData.bpm;
            newMeasure.coda = measureData.coda;
            newMeasure.fine = measureData.fine;
            newMeasure.segno = measureData.segno;
            newMeasure.primaryEnding = measureData.primaryEnding;
            newMeasure.secondaryEnding = measureData.secondaryEnding;
            newMeasure.timeDenominator = measureData.timeDenominator;
            newMeasure.timeNumerator = measureData.timeNumerator;
            newMeasure.page = newPage;
        }
    }
    
    NSArray *measuresInDB = [newScore measuresSortedByCoordinates];
    NSArray *measureDataObjects = [scoreImport measuresSortedByCoordinates];
    
    for (MeasureDataV3 *measureData in measureDataObjects) {
        NSInteger index = [measureDataObjects indexOfObject:measureData];
        Measure *measure = [measuresInDB objectAtIndex:index];
        
        if (nil != measureData.startRepeat && nil != measureData.startRepeat.endMeasure) {
            if (nil == measure.startRepeat) {
                Repeat *newRepeat = (Repeat *) [[NSManagedObject alloc] initWithEntity:[Repeat entityDescription] 
                                                        insertIntoManagedObjectContext:_context];
                newRepeat.numberOfRepeats = measureData.startRepeat.numberOfRepeats;
                newRepeat.startMeasure = measure;
                newRepeat.endMeasure = [measuresInDB objectAtIndex:[measureDataObjects indexOfObject:measureData.startRepeat.endMeasure]];
            }else {
#ifdef DEBUG
                NSLog(@"This should never happen.  Trying to restore duplicate start repeat during measure import");
#endif           
            }
        }
        
        if (nil != measureData.jumpOrigin && nil != measureData.jumpOrigin.destinationMeasure) {        
            if (nil == measure.jumpOrigin) {
                Jump *newJump = (Jump *) [[NSManagedObject alloc] initWithEntity:[Jump entityDescription]
                                                  insertIntoManagedObjectContext:_context];
                newJump.jumpType = measureData.jumpOrigin.jumpType;
                newJump.takeRepeats = measureData.jumpOrigin.takeRepeats;
                newJump.originMeasure = measure;
                newJump.destinationMeasure = [measuresInDB objectAtIndex:[measureDataObjects indexOfObject:measureData.jumpOrigin.destinationMeasure]];
            }else {
#ifdef DEBUG
                NSLog(@"This should never happen.  Trying to restore duplicate start jump origin during measure import");
#endif        
            }
        }
    }
#ifdef DEBUG        
    NSLog(@"ImportExportManager: imported score %@", newScore);
#endif      
    return newScore;
}

- (NSData*)exportScoreV3:(Score*)score withAnnotations:(BOOL)withAnnotations
{
    self._score = score;
    
    ScoreDataV3 *scoreExport = [[ScoreDataV3 alloc] init];
    scoreExport.name = _score.name;
    scoreExport.composer = _score.composer;
    scoreExport.genre = _score.genre;
    scoreExport.artist = _score.artist;
    scoreExport.playTime = _score.playTime;
    scoreExport.pages = [NSMutableArray array];
    scoreExport.metronomeBpm = _score.metronomeBpm;
    scoreExport.scrollSpeed = _score.scrollSpeed;
    scoreExport.automaticPlayTimeCalculation = _score.automaticPlayTimeCalculation;
    scoreExport.preferredPerformanceMode = _score.preferredPerformanceMode;
    scoreExport.metronomeNoteValue = _score.metronomeNoteValue;
    scoreExport.rotationAngle = _score.rotationAngle;
    
    NSArray *pages = [_score orderedPagesAsc];
    
    for (Page *page in pages) {
        PageDataV3 *pageExport = [[PageDataV3 alloc] init];
        [scoreExport.pages addObject:pageExport];
        pageExport.number = page.number;
        pageExport.score = scoreExport;
        
        if (withAnnotations) {
            pageExport.drawAnnotationsData = page.drawAnnotationsData;
            pageExport.textAnnotationsData = page.textAnnotationsData;
            pageExport.signAnnotationsData = page.signAnnotationsData;
        } else {
            pageExport.drawAnnotationsData = nil;
            pageExport.textAnnotationsData = nil;
        }
        
        pageExport.measures = [NSMutableArray array];
        
        NSArray *measures = [page measuresSortedByCoordinates];
        
        for (Measure *measure in measures) {
            MeasureDataV3 *measureExport = [[MeasureDataV3 alloc] init];
            [pageExport.measures addObject:measureExport];
            measureExport.coordinateAsString = measure.coordinateAsString;
            measureExport.bpm = measure.bpm;
            measureExport.coda = measure.coda;
            measureExport.fine = measure.fine;
            measureExport.segno = measure.segno;
            measureExport.primaryEnding = measure.primaryEnding;
            measureExport.secondaryEnding = measure.secondaryEnding;
            measureExport.timeDenominator = measure.timeDenominator;
            measureExport.timeNumerator = measure.timeNumerator;
            measureExport.jumpDestinations = [NSMutableSet set];
        }
    }
    
    NSArray *measuresOfScore = [_score measuresSortedByCoordinates];
    NSArray *measureDataObjects = [scoreExport measuresSortedByCoordinates];
    
    for (Measure *measure in measuresOfScore) {
        NSInteger indexOfMeasure = [measuresOfScore indexOfObject:measure];
        MeasureDataV3 *cachedMeasureExport = [measureDataObjects objectAtIndex:indexOfMeasure];
        
        if (nil != measure.startRepeat && nil != measure.startRepeat.endMeasure) {
            RepeatDataV3 *repeatExport = [[RepeatDataV3 alloc] init];
            repeatExport.numberOfRepeats = measure.startRepeat.numberOfRepeats;
            repeatExport.startMeasure = cachedMeasureExport;
            repeatExport.endMeasure = [measureDataObjects objectAtIndex:[measuresOfScore indexOfObject:measure.startRepeat.endMeasure]];
            cachedMeasureExport.startRepeat = repeatExport;
        }
        
        if (nil != measure.jumpOrigin && nil != measure.jumpOrigin.destinationMeasure) {
            JumpDataV3 *jumpExport = [[JumpDataV3 alloc] init];
            jumpExport.jumpType = measure.jumpOrigin.jumpType;
            jumpExport.takeRepeats = measure.jumpOrigin.takeRepeats;
            jumpExport.originMeasure = cachedMeasureExport;
            jumpExport.destinationMeasure = [measureDataObjects objectAtIndex:[measuresOfScore indexOfObject:measure.jumpOrigin.destinationMeasure]];
            cachedMeasureExport.jumpOrigin = jumpExport;
        }
    }
    
    return [NSKeyedArchiver archivedDataWithRootObject:scoreExport];
}


#pragma mark -
#pragma mark Memory Management



@end
