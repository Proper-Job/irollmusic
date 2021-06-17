//
//  scoreDataV1.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreDataV1.h"
#import "PageDataV1.h"


@implementation ScoreDataV1

@synthesize name, composer, genre, artist, playTime, pages, sha1Hash, metronomeBpm, scrollSpeed, automaticPlayTimeCalculation, preferredPerformanceMode;

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
}

- (NSArray *)measuresSortedByCoordinates
{
    NSMutableArray *measuresSorted = [NSMutableArray array];
    for (PageDataV1 *pageData in self.pages) {
        [measuresSorted addObjectsFromArray:[pageData measuresSortedByCoordinates]];
    }
    return [NSArray arrayWithArray:measuresSorted];
}
#pragma mark -
#pragma mark Memory Management

@end
