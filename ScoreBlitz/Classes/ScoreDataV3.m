//
//  ScoreDataV3.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScoreDataV3.h"
#import "PageDataV3.h"

@implementation ScoreDataV3

@synthesize name, composer, genre, artist, playTime, pages, sha1Hash, metronomeBpm, scrollSpeed, automaticPlayTimeCalculation, preferredPerformanceMode;
@synthesize metronomeNoteValue, rotationAngle;

- (id)init
{
	self = [super init];
	if (self != nil) {
        
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    name = [aDecoder decodeObjectForKey:@"name"];
    composer = [aDecoder decodeObjectForKey:@"composer"];
    genre = [aDecoder decodeObjectForKey:@"genre"];
    artist = [aDecoder decodeObjectForKey:@"artist"];
    playTime = [aDecoder decodeObjectForKey:@"playTime"];
    pages = [aDecoder decodeObjectForKey:@"pages"];
    sha1Hash = [aDecoder decodeObjectForKey:@"sha1Hash"];
    metronomeBpm = [aDecoder decodeObjectForKey:@"metronomeBpm"];
    scrollSpeed = [aDecoder decodeObjectForKey:@"scrollSpeed"];
    automaticPlayTimeCalculation = [aDecoder decodeObjectForKey:@"automaticPlayTimeCalculation"];
    preferredPerformanceMode = [aDecoder decodeObjectForKey:@"preferredPerformanceMode"];
    metronomeNoteValue = [aDecoder decodeObjectForKey:@"metronomeNoteValue"];
    rotationAngle = [aDecoder decodeObjectForKey:@"rotationAngle"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.composer forKey:@"composer"];
    [aCoder encodeObject:self.genre forKey:@"genre"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.playTime forKey:@"playTime"];
    [aCoder encodeObject:self.pages forKey:@"pages"];
    [aCoder encodeObject:self.sha1Hash forKey:@"sha1Hash"];
    [aCoder encodeObject:self.metronomeBpm forKey:@"metronomeBpm"]; 
    [aCoder encodeObject:self.scrollSpeed forKey:@"scrollSpeed"]; 
    [aCoder encodeObject:self.automaticPlayTimeCalculation forKey:@"automaticPlayTimeCalculation"]; 
    [aCoder encodeObject:self.preferredPerformanceMode forKey:@"preferredPerformanceMode"]; 
    [aCoder encodeObject:self.metronomeNoteValue forKey:@"metronomeNoteValue"]; 
    [aCoder encodeObject:self.rotationAngle forKey:@"rotationAngle"];     
}

- (NSArray *)measuresSortedByCoordinates
{
    NSMutableArray *measuresSorted = [NSMutableArray array];
    for (PageDataV3 *pageData in self.pages) {
        [measuresSorted addObjectsFromArray:[pageData measuresSortedByCoordinates]];
    }
    return [NSArray arrayWithArray:measuresSorted];
}
#pragma mark -
#pragma mark Memory Management

@end

