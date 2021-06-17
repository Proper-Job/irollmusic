//
//  Score.m
//  ScorePad
//
//  Created by Moritz Pfeiffer on 13.12.10.
//  Copyright 2010 Alp Phone. All rights reserved.
//

#import "Score.h"
#import "ScoreBlitzAppDelegate.h"
#import "Page.h"
#import "PerformanceManager.h"

@implementation Score

@dynamic artist, composer, pdfFileName, genre, name, canvasHeightPortrait, canvasHeightLandscape, sha1Hash, pages, setListEntries;
@dynamic preferredPerformanceMode, playTime;
@dynamic isAnalyzed;
@dynamic metronomeBpm;
@dynamic scrollSpeed;
@dynamic automaticPlayTimeCalculation;
@dynamic rotationAngle;
@dynamic metronomeNoteValue;

@synthesize orderedPagesAsc, orderedPagesDesc;

+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"Score" inManagedObjectContext:context];
}


- (void)awakeFromInsert{
	[super awakeFromInsert];
	
	self.name = [NSString string];
	self.artist = [NSString string];
	self.composer = [NSString string];
    self.pdfFileName = [NSString string];
	self.genre = [NSString string];
    self.playTime = [NSNumber numberWithInt:0];
    self.isAnalyzed = [NSNumber numberWithBool:NO];
    self.metronomeBpm = [NSNumber numberWithInt:60];
    self.scrollSpeed = [NSNumber numberWithInt:10];
    self.automaticPlayTimeCalculation = [NSNumber numberWithBool:YES];
    self.rotationAngle = [NSNumber numberWithInt:0];
    self.metronomeNoteValue = kQuarterNote;
}


- (NSString*)pdfFilePath
{
    if (nil == self.pdfFileName) {
        return nil;
#ifdef DEBUG        
        [NSException raise:@"Cannot create pdfFilePath:" format:@"Set pdfFileName first!"];
#endif
    } else {
        return [[self scoreDirectory] stringByAppendingPathComponent:self.pdfFileName];
    }
    
}

- (NSURL *)scoreUrl
{
    return [NSURL fileURLWithPath:[self pdfFilePath]];
}

- (NSString*)scoreDirectory
{
    if (nil == self.sha1Hash) {
        return nil;
#ifdef DEBUG        
        [NSException raise:@"Cannot create ScoreDirectory:" format:@"Set sha1Hash first!"];
#endif
    } else {
        ScoreBlitzAppDelegate *appDelegate = (ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate];
        return [[[appDelegate applicationScoreDirectory] path] stringByAppendingPathComponent:self.sha1Hash];
    }
}

- (NSString *)playTimeString
{
   NSInteger playTime = [self.playTime intValue];
    
   
   NSInteger minutes = playTime / 60;
   NSInteger seconds = playTime % 60;
    
    NSString *playTimeString = [MyLocalizedString(@"tableViewCellPlayTime", nil) stringByAppendingString:@": "];

    if (playTime == 0) {
        playTimeString = [playTimeString stringByAppendingString:MyLocalizedString(@"tableViewCellPlayTimeNotAvailableString", nil)];
    } else {
        playTimeString = [playTimeString stringByAppendingFormat:@"%d:%02d", minutes, seconds];
    }
    
   return playTimeString;
}

- (void)refreshPlaytime
{
    if ([self.automaticPlayTimeCalculation boolValue]) {
        self.playTime = @([[[PerformanceManager alloc] initWithScore:self
                                                            delegate:nil
                                                     performanceMode:PerformanceModeAdvancedScroll
                                             playtimeCalculationOnly:YES] performanceDuration]);
    }
}

- (NSArray *)measuresSortedByCoordinates
{
    NSMutableArray *measuresSorted = [NSMutableArray array];
    for (Page *page in self.orderedPagesAsc) {
        [measuresSorted addObjectsFromArray:[page measuresSortedByCoordinates]];
    }
    return [NSArray arrayWithArray:measuresSorted];
}


#pragma mark -
#pragma mark Custom Accessors

- (NSArray *)orderedPagesAsc
{
	// Cache descriptor?
	NSSortDescriptor *pageNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:pageNumberDescriptor];
	return [self.pages sortedArrayUsingDescriptors:sortDescriptors];
}


- (NSArray *)orderedPagesDesc
{
	// Cache descriptor?
	NSSortDescriptor *pageNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:pageNumberDescriptor];
	return [self.pages sortedArrayUsingDescriptors:sortDescriptors];
}

- (CGFloat)canvasHeight
{
    // This is actually identical to the value in self.canvasHeightPortrait and self.canvasHeightLandscape.
    // But let's move away from that crazy approach and make score display more dynamic.
    return [self.canvasHeightPortrait floatValue];
}

@end
