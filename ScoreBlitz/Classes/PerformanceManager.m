//
//  ScrollingManager.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerformanceManager.h"
#import "Score.h"
#import "Page.h"
#import "Measure.h"
#import "Repeat.h"
#import "Jump.h"
#import "PerformanceScrollingViewController.h"
#import "MetricsManager.h"
#import <mach/mach_time.h>
#import <AVFoundation/AVFoundation.h>

@interface PerformanceManager ()

#pragma mark Private properties

@property (nonatomic, strong) NSArray *measuresOfScore;
@property (nonatomic, strong) NSMutableArray *executedJumps, *scrollPositions;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDictionary *countInContext;
@property (nonatomic, assign) NSInteger countInBeat;
@property (atomic, assign) RemoteContext *alternateContext, *remoteContext;
@property (nonatomic, assign) BOOL goToCoda, playTillFine, playTillSegno, executeRepeat;

#pragma mark Private Instance Methods
- (void)scrollToMeasureAtIndex:(NSUInteger)measureIndex;
- (void)createScrollPositions;
- (CGFloat)scrollPositionBoxHeight;
- (NSTimeInterval)nonContinuousSimpleTimerInterval;
- (void)setupRemoteIO;
static OSStatus playbackCallback(void *inRefCon, 
                                 AudioUnitRenderActionFlags *ioActionFlags, 
                                 const AudioTimeStamp *inTimeStamp, 
                                 UInt32 inBusNumber, 
                                 UInt32 inNumberFrames, 
                                 AudioBufferList *ioData);
void loadClickData(RemoteContext *remoteContext);
void CheckStatus(OSStatus status, const char *operation);
//void rioInterruptionListener(void *inClientData, UInt32 inInterruption);
void printASBD(AudioStreamBasicDescription asbd);
@end

@implementation PerformanceManager

- (id)initWithScore:(Score *)score 
           delegate:(id)theDelegate
    performanceMode:(PerformanceMode)theMode
playtimeCalculationOnly:(BOOL)playtimeOnly
{
	self = [super init];
	if (self != nil) {
        self.activeScore = score;
        self.delegate = theDelegate;
        self.performanceMode = theMode;
        self.playtimeCalcOnly = playtimeOnly;

        self.canvasHeight = [self.activeScore canvasHeight];
        self.canvasHeight += ([self.activeScore.pages count] -1) * [MetricsManager scrollingPagePadding];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(simpleScrollSpeedDidChange)
                                                     name:kSimpleScrollSpeedDidChangeNotification
                                                   object:nil];

        self.remoteContext = (RemoteContext *) malloc(sizeof(RemoteContext));
        if (!self.playtimeCalcOnly) {
            [self setupRemoteContext:self.remoteContext loadClick:YES];
            [self setupRemoteIO];
        }else {
            [self setupRemoteContext:self.remoteContext loadClick:NO];
        }
    }
	return self;
}

- (void)setupRemoteContext:(RemoteContext *)context loadClick:(BOOL)loadClick
{
    memset (&(context->clickDescription), 0, sizeof (AudioStreamBasicDescription));
    context->clickDescription.mSampleRate           = kSampleRate;
    context->clickDescription.mFormatID             = kAudioFormatLinearPCM;
    context->clickDescription.mFormatFlags          = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    context->clickDescription.mFramesPerPacket      = 1; //For uncompressed audio, the value is 1
    context->clickDescription.mChannelsPerFrame     = kNumberOfChannels;
    context->clickDescription.mBitsPerChannel       = 8 * bitDepthBytes;
    context->clickDescription.mBytesPerPacket       = context->clickDescription.mChannelsPerFrame * bitDepthBytes;
    context->clickDescription.mBytesPerFrame		= context->clickDescription.mChannelsPerFrame * bitDepthBytes;
    
    //#ifdef DEBUG
    //          NSLog(@"Metronome audio stream description:");
    //          printASBD(remoteContext.clickDescription);
    //#endif
    
    struct mach_timebase_info timebase;
    mach_timebase_info(&timebase);
    context->timebase_ratio = ((double)timebase.numer / (double)timebase.denom) * 1.0e-9;
    context->metronomeAudible = [[NSUserDefaults standardUserDefaults] boolForKey:kMetronomeAudible];
    context->visualMetronome = [[NSUserDefaults standardUserDefaults] boolForKey:kVisualMetronome];
    context->countInTimeline = NULL;
    context->countInTimelineLength = 0;
    context->countInPtr = NULL;
    context->countIn = false;
    context->measurePtr = NULL;
    context->measureTimeline = NULL;
    context->measureTimelineLength = 0;
    context->measurePtr = NULL;
    context->clickTimeline = NULL;
    context->clickTimelineLength = 0;
    context->clickPtr = NULL;
    context->clickLengthFrames = 0;
    context->currentClickFrame = UINT32_MAX; // .35 seconds of silence precedes audio output when count in is enabled
    context->click = NULL;
    context->performanceManager = self;
    
    if (loadClick) {
        loadClickData(context);
    }
}

#pragma mark - Air turn helpers

- (void)airTurnEvent
{
    if (self.playbackIndex + 1 < [self.timeline count]) {
        if (nil != self.alternateContext) {
            free(self.alternateContext->measureTimeline);
            free(self.alternateContext->clickTimeline);
            free(self.alternateContext->countInTimeline);
            free(self.alternateContext);
            self.alternateContext = nil;
        }
        
        self.alternateContext = (RemoteContext *)malloc(sizeof(RemoteContext));
        [self setupRemoteContext:self.alternateContext loadClick:NO];
        
        NSUInteger index = self.playbackIndex + 1;
        [self setupMeasureAndClickTimeline:self.alternateContext countInFinishTime:0 playBackIndex:index];
        self.alternateContext->audioUnitRunning = true;
        self.alternateContext->click = self.remoteContext->click;
        self.alternateContext->clickLengthFrames = self.remoteContext->clickLengthFrames;
    }
}

#pragma mark - Performance Controls

- (void)play
{
    if ([self isPlaying]) {
        return;
    }
    
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        if (nil != self.startMeasure) {
            self.playbackIndex = [self.timeline indexOfObject:self.startMeasure];
            self.activeMeasure = self.timeline[self.playbackIndex];
            
            
            NSError *audioSessionError = nil;
            AVAudioSession *mySession = [AVAudioSession sharedInstance];
            
            //mySession.delegate = self;
            
            // Set sample rate
            [mySession setPreferredSampleRate:kSampleRate
                                        error:&audioSessionError];
#ifdef DEBUG
            if (nil != audioSessionError) {
                NSLog(@"Error setting preferred sample rate: %@, %s %d", audioSessionError, __FUNCTION__, __LINE__);
                audioSessionError = nil;
            }
#endif
            
            // Set category
            [mySession setCategory:AVAudioSessionCategoryAmbient
                             error:&audioSessionError];
#ifdef DEBUG
            if (nil != audioSessionError) {
               NSLog(@"Error setting audio category: %@ %s %d", audioSessionError, __FUNCTION__, __LINE__); 
                audioSessionError = nil;
            }
#endif
            
            // Set buffer duration
            [mySession setPreferredIOBufferDuration:.005
                                              error:&audioSessionError];
#ifdef DEBUG
            if (nil != audioSessionError) {
                NSLog(@"Error setting preferred buffer duration: %@ %s %d", audioSessionError, __FUNCTION__, __LINE__); 
                audioSessionError = nil;
            }
#endif

            // Activate session
            [mySession setActive:YES
                           error:&audioSessionError];
#ifdef DEBUG
            if (nil != audioSessionError) {
                NSLog(@"Error activating audio session: %@ %s %d", audioSessionError, __FUNCTION__, __LINE__); 
                audioSessionError = nil;
            }
#endif
            
            UInt64 mach_countin_finish_time = [self setupCountInTimeLine:self.remoteContext];
            [self setupMeasureAndClickTimeline:self.remoteContext countInFinishTime:mach_countin_finish_time playBackIndex:self.playbackIndex];
            [self scrollToMeasureAtIndex:self.playbackIndex];
            self.remoteContext->metronomeAudible = [[NSUserDefaults standardUserDefaults] boolForKey:kMetronomeAudible];
            self.remoteContext->visualMetronome = [[NSUserDefaults standardUserDefaults] boolForKey:kVisualMetronome];
            self.remoteContext->mach_start_time = mach_absolute_time();
            
            OSStatus status = AudioOutputUnitStart(audioUnit);
            if (noErr == status) {
                self.remoteContext->audioUnitRunning = true;
            }
#ifdef DEBUG
            CheckStatus(status, "Couldn't start Remote IO audio unit");
#endif
        }else {
#ifdef DEBUG
            NSLog(@"Trying to play in advanced mode without start measure!");
#endif
        }
    }else {
        self.continuousScroll = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingSimpleModeScrollsContinuously];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                       target:self 
                                                     selector:@selector(simpleScroll) 
                                                     userInfo:@{kStartTimerFlag : @YES}
                                                      repeats:NO];
    }
}

- (BOOL)isPlaying
{
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        return self.remoteContext->audioUnitRunning;
    }else {
        return nil != self.timer;
    }
}

- (void)stop 
{
    if (PerformanceModeAdvancedScroll == self.performanceMode) {
        OSStatus status = AudioOutputUnitStop(audioUnit);
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
#ifdef DEBUG
        CheckStatus(status, "Couldn't stop Remote IO audio unit, maybe already stopped?");
        if (nil != error) {
            NSLog(@"Error %@ %s %d", [error localizedDescription], __FUNCTION__, __LINE__);
        }
#endif
        self.remoteContext->audioUnitRunning = false;
        self.remoteContext->currentClickFrame = UINT32_MAX;
        
        free(self.remoteContext->measureTimeline);
        free(self.remoteContext->clickTimeline);
        free(self.remoteContext->countInTimeline);
        
        self.remoteContext->measureTimeline = NULL;
        self.remoteContext->clickTimeline = NULL;
        self.remoteContext->countInTimeline = NULL;
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(removeCountInView)]) {
            [self.delegate removeCountInView];
        }
    }else {
        if (nil != self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

- (void)pause
{
    if (nil != self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Timeline creation

- (UInt64)setupCountInTimeLine:(RemoteContext *)context
{
    UInt64 initial_silence = (UInt64) (.35 / context->timebase_ratio);
    UInt64 mach_countin_finish_time = initial_silence; //silence before starting output to hide initial wobble
    UInt64 countInNumberOfBars = (UInt64) [[NSUserDefaults standardUserDefaults] integerForKey:kMetronomeCountInNumberOfBars];
    if (countInNumberOfBars > 0) {
        [self.delegate prepareCountInView];
        context->countIn = true;
        self.countInBeat = 0;
        
        double metronomeNoteValue = [Helpers doubleValueForNoteValue:self.activeScore.metronomeNoteValue];
        double startMeasureNoteValue = [Helpers doubleValueForTimeDenominator:self.startMeasure.timeDenominator];
        double commonDenominatorFactor = startMeasureNoteValue / metronomeNoteValue;
        double countInNumberOfBeats = [self.startMeasure.timeNumerator doubleValue] * commonDenominatorFactor;
        
        UInt64 bpm = 0;
        UInt64 numberOfBeats = 0;
        
        double integralBeats;
        if (modf(countInNumberOfBeats, &integralBeats) > 0) {
            // Cannot count in using the metronome note value.
            // Use start measure time denominator instead
            numberOfBeats = [self.startMeasure.timeNumerator unsignedLongValue];
            bpm = (UInt64) round(
                    [self.activeScore.metronomeBpm doubleValue] / commonDenominatorFactor +
                            [self.startMeasure.bpm doubleValue]
            );
        }else {
            bpm = [self.activeScore.metronomeBpm unsignedLongValue] + [self.startMeasure.bpm unsignedLongValue];
            numberOfBeats = (UInt64) round(countInNumberOfBeats);
        }
        
        numberOfBeats *= countInNumberOfBars;
        
        context->countInTimelineLength = numberOfBeats + 1; // + 1 to remove count in view
        context->countInTimeline = (UInt64 *)calloc(context->countInTimelineLength, sizeof(UInt64));
        context->countInPtr = context->countInTimeline;
        context->countInTimeline[0] = initial_silence;
        
        UInt64 mach_duration = (UInt64) ((60.0 / bpm) / context->timebase_ratio);
        for (int i = 1; i < numberOfBeats; i++) { // context->countInTimeline[0] was calloced to 0
            context->countInTimeline[i] = context->countInTimeline[i - 1] + mach_duration;
            //NSLog(@"Timeinterval: %f", context->countInTimeline[i] * context->timebase_ratio);
        }
        mach_countin_finish_time += mach_duration * numberOfBeats;
        context->countInTimeline[context->countInTimelineLength - 1] = mach_countin_finish_time;
        
        // NSLog(@"Count in finish time: %f", mach_countin_finish_time * context->timebase_ratio);
        
        self.countInContext = @{
                kCountInContextNumberOfBeats : @(numberOfBeats),
                kCountInContextNumberOfBars : @(countInNumberOfBars)
        };
    }else {
        context->countIn = false;
    }
    return mach_countin_finish_time;
}

- (void)setupMeasureAndClickTimeline:(RemoteContext *)context
                   countInFinishTime:(UInt64)mach_countin_finish_time
                       playBackIndex:(NSUInteger)index
{
    NSArray *timelineRange = [self.timeline subarrayWithRange:NSMakeRange(index, [self.timeline count] - index)];
    context->measureTimelineLength = (UInt64)[timelineRange count];
    context->measureTimeline = (UInt64 *) calloc(context->measureTimelineLength, sizeof(UInt64));
    context->measurePtr = context->measureTimeline;
    context->measureTimeline[0] = mach_countin_finish_time;
    
    NSInteger i = 0; // context->measureTimeline[0] was set to mach_countin_finish_time
    for (Measure *aMeasure in timelineRange) {
        context->measureTimeline[i] += [aMeasure duration] / context->timebase_ratio;
        if (i > 0) {
            context->measureTimeline[i] += context->measureTimeline[i - 1];
        }
        //NSLog(@"Timeinterval: %f", context->measureTimeline[i] * context->timebase_ratio);
        i++;
    }
    
    // Sort measures into two dimensional array based on consecutive measures with the same bpm value
    NSMutableArray *bpmSlices = [NSMutableArray array];
    [bpmSlices addObject:[NSMutableArray array]];
    
    NSInteger currentBpm = [self.startMeasure.bpm intValue];
    NSMutableArray *currentSlice = bpmSlices[0];
    
    for (Measure *aMeasure in timelineRange) {
        if ([aMeasure.bpm intValue] != currentBpm) {
            NSMutableArray *newSlice = [@[aMeasure] mutableCopy];
            [bpmSlices addObject:newSlice];
            currentSlice = newSlice;
            currentBpm = [aMeasure.bpm intValue];
        }else {
            [currentSlice addObject:aMeasure];
        }
    }
    
    // Get click count
    UInt32 timelineLength = 0;
    double metronomeNoteValue = [Helpers doubleValueForNoteValue:self.activeScore.metronomeNoteValue];
    for (NSMutableArray *slice  in bpmSlices) {
        double sliceClickCount = 0.0;
        for (Measure *aMeasure in slice) {
            double myNoteValue = [Helpers doubleValueForTimeDenominator:aMeasure.timeDenominator];
            double commonDenominatorFactor = myNoteValue / metronomeNoteValue;
            sliceClickCount += [aMeasure.timeNumerator doubleValue] * commonDenominatorFactor;
        }
        NSInteger wholeClicks = (NSInteger)sliceClickCount;
        if (sliceClickCount - wholeClicks > 0) {
            wholeClicks++;
        }
        timelineLength += wholeClicks;
    }
    
    
    // Allocate click timeline buffer
    context->clickTimeline = (UInt64 *)calloc(timelineLength, sizeof(UInt64));
    context->clickPtr = context->clickTimeline;
    context->clickTimelineLength = timelineLength;
    context->clickTimeline[0] = mach_countin_finish_time;
    
    
    // Compute clicks
    // Each slice writes the first click of the next slice
    // Which means that it doesn't write it's own first click
    NSUInteger clickIndex = 1;  // context->clickTimeline[0] was set to mach_countin_finish_time
    for (NSMutableArray *slice in bpmSlices) {
        
        double sliceClickCount = 0.0;
        
        for (Measure *aMeasure in slice) {
            double myNoteValue = [Helpers doubleValueForTimeDenominator:aMeasure.timeDenominator];
            double commonDenominatorFactor = myNoteValue / metronomeNoteValue;
            sliceClickCount += [aMeasure.timeNumerator doubleValue] * commonDenominatorFactor;
        }
        
        NSInteger sliceBpm = [[slice[0] bpm] intValue];
        NSTimeInterval clickDuration = 60.0 / ([self.activeScore.metronomeBpm intValue] + sliceBpm);
        NSInteger wholeClicks = (NSInteger)sliceClickCount;
        double clickRemainder = sliceClickCount - wholeClicks;
        
        double clickDurationFactor = 1.0;
        if (clickRemainder > 0) {
            clickDurationFactor = clickRemainder;
            wholeClicks++;
        }
        
        for (int i = 1; i < wholeClicks; i++, clickIndex++) {
            context->clickTimeline[clickIndex] = (UInt64) (clickDuration / context->timebase_ratio);
            context->clickTimeline[clickIndex] += context->clickTimeline[clickIndex - 1];
        }
        
        // Write the first click of the next slice
        if (![slice isEqual:[bpmSlices lastObject]]) {
            context->clickTimeline[clickIndex] = (UInt64) ((clickDuration * clickDurationFactor) / context->timebase_ratio);
            context->clickTimeline[clickIndex] += context->clickTimeline[clickIndex - 1];
            clickIndex++;
        }
    }
    //            for (int i = 0; i < timelineLength; i++) {
    //                NSLog(@"Timeinterval: %f", context->clickTimeline[i] * context->timebase_ratio);
    //            }
    
    context->mach_start_time = mach_absolute_time();
}


#pragma mark - Simple Performance

- (void)simpleScrollSpeedDidChange
{
    if ([self isPlaying]) {
        [self.timer invalidate];
        self.timer = nil;
        
        NSTimeInterval duration;
        if (self.continuousScroll) {
            duration = 0.0;
        }else {
            duration = [self nonContinuousSimpleTimerInterval];
        } 
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                       target:self 
                                                     selector:@selector(simpleScroll) 
                                                     userInfo:@{kStartTimerFlag : @YES}
                                                      repeats:NO];
    }
}


- (void)simpleScroll
{
    CGFloat factor = self.delegate.performanceScrollView.maximumZoomScale / self.delegate.performanceScrollView.zoomScale;
    CGFloat currentPositionX = [self.delegate scrollViewBoundsInPageCoordinates].origin.x;
    CGFloat currentPositionY = [self.delegate scrollViewBoundsInPageCoordinates].origin.y;
    BOOL startTimer = [[[self.timer userInfo] objectForKey:kStartTimerFlag] boolValue];

    CGFloat frameHeight = [self.delegate contentFrame].size.height;
    if (self.continuousScroll) {
        currentPositionY += [self.activeScore.scrollSpeed intValue] * 2.0f;
    }else {
        currentPositionY += [MetricsManager simpleScrollStep];
    }
    
    if (currentPositionY <= self.canvasHeight - frameHeight * factor) {
        [self.delegate scrollToPoint:CGPointMake(currentPositionX, currentPositionY)];
        if (startTimer) {
            [self.timer invalidate];
            self.timer = nil;
            
            NSTimeInterval intervalDuration;
            if (self.continuousScroll) {
                intervalDuration = kContinuousScrollAnimationDuration;
            }else {
                intervalDuration = [self nonContinuousSimpleTimerInterval];
            }

            self.timer = [NSTimer scheduledTimerWithTimeInterval:intervalDuration
                                                           target:self 
                                                         selector:@selector(simpleScroll) 
                                                         userInfo:@{kStartTimerFlag : @NO}
                                                          repeats:YES];
        }
    }else {
        if (nil != self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        currentPositionY = roundf(self.canvasHeight - frameHeight * factor);
        [self.delegate scrollToPoint:CGPointMake(currentPositionX, currentPositionY)];
        [self.delegate finishedSimplePlayback];
    }
}

- (NSTimeInterval)nonContinuousSimpleTimerInterval
{
    return [MetricsManager simpleScrollStep] /
            (([self.activeScore.scrollSpeed doubleValue] * 2.0) * (kOneSecond / kContinuousScrollAnimationDuration));
}


#pragma mark - Advanced Performance 

- (void)updateCountInView
{
    NSInteger beats = [self.countInContext[kCountInContextNumberOfBeats] integerValue];
    NSInteger bars = [self.countInContext[kCountInContextNumberOfBars] integerValue];
    NSInteger beatsPerBar = beats / bars;
    NSInteger currentBeat = (self.countInBeat % beatsPerBar) + 1;
    
    if (self.countInBeat < beats) {
        [self.delegate updateCountInViewWithBeat:@(currentBeat)];
    }else {
        [self.delegate finishCountIn];
    }
    self.countInBeat++;
}

- (void)showCurrentMeasure
{
    [self showMeasureAtIndex:self.playbackIndex];
}

- (void)showNextMeasure
{
    self.playbackIndex++;
    [self showMeasureAtIndex:self.playbackIndex];
}

- (void)showMeasureAtIndex:(NSUInteger)measureIndex
{
    if (measureIndex < [self.timeline count]) {
        if (nil != self.alternateContext) {
            UInt64 *oldMeasureTimeline = self.remoteContext->measureTimeline;
            UInt64 *oldClickTimeline = self.remoteContext->clickTimeline;
            UInt64 *oldCountInTimeline = self.remoteContext->countInTimeline;
            
            self.alternateContext->mach_start_time = mach_absolute_time();
            //memcpy(self.remoteContext, self.alternateContext, sizeof(RemoteContext));
            *self.remoteContext = *self.alternateContext;
            
            free(oldMeasureTimeline);
            free(oldClickTimeline);
            free(oldCountInTimeline);
            free(self.alternateContext);
            self.alternateContext = nil;
        }
        self.activeMeasure = self.timeline[measureIndex];
        [self scrollToMeasureAtIndex:measureIndex];
    }else {
        [self stop];
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(finishedPlayback)]) {
            [self.delegate finishedPlayback];
        }
    }
}

- (void)visualClick
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(showVisualClick)]) {
        [self.delegate showVisualClick];
    }
}

- (void)scrollToMeasureAtIndex:(NSUInteger)measureIndex
{
    if (nil != self.delegate) {
        PerformanceScrollPosition scrollPosition = (PerformanceScrollPosition) [[NSUserDefaults standardUserDefaults] integerForKey:kSettingScrollPosition];
        if (PerformanceScrollPositionAutomatic == scrollPosition) {
            scrollPosition = (PerformanceScrollPosition) [self.scrollPositions[measureIndex] intValue];
        }
        CGPoint position = [self measurePositionOnCanvas:self.timeline[measureIndex]];
        [self.delegate scrollToMeasureAtPoint:position
                                     animated:YES
                               scrollPosition:scrollPosition];
        [self.delegate highlightMeasureAtPoint:position];
    } else if (APP_DEBUG) {
        NSLog(@"Delegate not set! %s %d", __FUNCTION__, __LINE__);
    }
}

- (CGPoint)measurePositionOnCanvas:(Measure *)measure
{
    NSInteger pageNumber = [measure.page.number integerValue];
    Page *thePage = measure.page;
    CGFloat xFloat = [[measure xCoordinate] floatValue] * [MetricsManager scoreWidthAtFullScale];
    CGFloat yFloat = [thePage height] * [[measure yCoordinate] floatValue] + [thePage positionOnCanvas];
    
    if (pageNumber > 0) {
        yFloat += (pageNumber - 1) * [MetricsManager scrollingPagePadding];
    }
    
    // Make coordinates integer
    xFloat = roundf(xFloat);
    yFloat = roundf(yFloat);
    
    return CGPointMake(xFloat, yFloat);
}

#pragma mark -  Data Operations

- (void)createTimelineWithScrollPositions:(BOOL)createScrollPositions
{
#ifdef DEBUG
    NSLog(@"Creating timeline");
#endif  
    self.goToCoda = NO;
    self.playTillFine = NO;
    self.playTillSegno = NO;
    self.executeRepeat = YES;
    
    self.executedJumps = [NSMutableArray array];
    self.timeline = [NSMutableArray array];
    self.measuresOfScore = [self.activeScore measuresSortedByCoordinates];
    
    NSUInteger measureIndex = 0;
    
    while (measureIndex < [self.measuresOfScore count]) {
        Measure *measure = self.measuresOfScore[measureIndex];
        [self.timeline addObject:measure];
        
        if (nil != measure.endRepeat) {
            if (self.executeRepeat) {
                NSUInteger startIndex = [self.measuresOfScore indexOfObject:measure.endRepeat.startMeasure];
                NSUInteger lengthIndex = [self.measuresOfScore indexOfObject:measure] - startIndex + 1; // Include measure
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, lengthIndex)];
                NSMutableArray *repeatedMeasures = [NSMutableArray arrayWithArray:[self.measuresOfScore objectsAtIndexes:indexSet]];
                NSInteger numberOfRepeats = [[measure.endRepeat numberOfRepeats] intValue];
                
                for (int counter = 1; counter <= numberOfRepeats; counter++) {
                    
                    if (counter == numberOfRepeats) { // On the last pass
                        // Skip first ending measures
                        NSMutableArray *firstEndingSubset = [NSMutableArray array];
                        for (Measure *aMeasure in [repeatedMeasures reverseObjectEnumerator]) {
                            if ([aMeasure.primaryEnding boolValue]) {
                                [firstEndingSubset addObject:aMeasure];
                            }else {
                                break;
                            }
                        }
                        if ([firstEndingSubset count] > 0) { // Comparison to avoid the overhead of searching the contents
                            [repeatedMeasures removeObjectsInArray:firstEndingSubset];
                        }   
                    }
                    
                    [self.timeline addObjectsFromArray:repeatedMeasures];
                }
            }else if ([measure.primaryEnding boolValue]) {
                // We've done a jump that disallows repeats
                NSMutableIndexSet *goners = [[NSMutableIndexSet alloc] init];
                NSUInteger length = [self.timeline count];
                for (int i = 1; i <= length; i++) {
                    Measure *ancestor = self.timeline[length - i];
                    if ([ancestor.primaryEnding boolValue]) {
                        [goners addIndex:length - i];
                    }else {
                        // Only allow consecutive primary ending measures
                        break;
                    }
                }
                // remove first ending measures that have already been added to the timeline
                [self.timeline removeObjectsAtIndexes:goners];
            }
        }
        
        APJumpType jumpType = APJumpTypeNone;
        if ([measure isJumpOrigin:&jumpType] && ![self.executedJumps containsObject:@(jumpType)]) {
            Jump *theJump = measure.jumpOrigin;
            NSUInteger targetMeasureIndex = [self.measuresOfScore indexOfObject:theJump.destinationMeasure];
            
            if (APJumpTypeGoToCoda == jumpType) {
                if (self.goToCoda) {
                    measureIndex = targetMeasureIndex;
                    self.executeRepeat = YES;
                    self.goToCoda = NO;
                    [self.executedJumps addObject:@(jumpType)];
                }else {
                    measureIndex++;
                }
            }else {
                BOOL match = YES;
                switch (jumpType) {
                    case APJumpTypeDaCapoAlCoda: // fall through
                    case APJumpTypeDalSegnoAlCoda:
                        self.goToCoda = YES;
                        self.playTillFine = NO;
                        self.playTillSegno = NO;
                        break;
                    case APJumpTypeDaCapoAlSegno:
                        self.playTillSegno = YES;
                        self.playTillFine = NO;
                        self.goToCoda = NO;
                        break;
                    case APJumpTypeDaCapoAlFine: // fall through
                    case APJumpTypeDalSegnoAlFine:
                        self.playTillFine = YES;
                        self.goToCoda = NO;
                        self.playTillSegno = NO;
                        break;
                    case APJumpTypeDalSegno: // fall through
                    case APJumpTypeDaCapo:
                        self.playTillSegno = NO;
                        self.playTillFine = NO;
                        self.goToCoda = NO;
                        break;
                    case APJumpTypeNone:
                        match = NO;
                        break;
                }
                if (match) {
                    self.executeRepeat = [theJump.takeRepeats boolValue];
                    measureIndex = targetMeasureIndex;
                    [self.executedJumps addObject:@(jumpType)];
                }else {
                    measureIndex++;
                }
            }
        }else {
            if ([measure.fine boolValue] && self.playTillFine) {
                break;
            }
            if ([measure.segno boolValue] && self.playTillSegno) {
                break;
            }
            
            measureIndex++;
        } 
    }
    /*
    for (Measure *aMeasure in self._timeline) {
        NSLog(@"%@", [aMeasure objectID]);
    }
    */
    
    if (createScrollPositions) {
        [self createScrollPositions];
    }
}

- (void)createScrollPositions
{
    self.scrollPositions = [[NSMutableArray alloc] init];

    // Sort timeline into systems
    CGFloat systemY = MAXFLOAT;
    NSMutableArray *systems = [[NSMutableArray alloc] init];
    for (Measure *measure in self.timeline) {
        CGPoint positionOnCanvas = [self measurePositionOnCanvas:measure];
        if (equalsf(positionOnCanvas.y, systemY)) {
            [[systems lastObject] addObject:measure];
        }else {
            systemY = positionOnCanvas.y;
            [systems addObject:[@[measure] mutableCopy]];
        }
        //NSLog(@"systemY: %f", systemY);
    }

    CGFloat targetBoxHeight = [self scrollPositionBoxHeight];
    CGFloat sameBox = targetBoxHeight / 2.0f;
    CGFloat adjacentBox = sameBox * 3.0f;
    //NSLog(@"same box: %f, adjacentBox: %f", sameBox, adjacentBox);
    for (NSMutableArray *system in systems) {
        PerformanceScrollPosition scrollPosition = PerformanceScrollPositionTop;
        NextSystemPosition systemPosition = NextSystemPositionNone;
        CGFloat currentSystemY = [self measurePositionOnCanvas:[system lastObject]].y;

        BOOL goOn = YES;
        for(NSUInteger i = [systems indexOfObject:system] + 1; i < [systems count] && goOn; i++) {
            CGFloat nextSystemY = [self measurePositionOnCanvas:[systems[i] lastObject]].y;
            CGFloat systemDiff = nextSystemY - currentSystemY;
            //NSLog(@"system diff: %f", systemDiff);
            if (systemDiff > 0) {
                if (systemDiff < sameBox) {
                    continue;
                }else if (systemDiff < adjacentBox) {
                    switch (systemPosition) {
                        case NextSystemPositionNone: // fall through
                        case NextSystemPositionBottomAdjacent:
                            systemPosition |= NextSystemPositionBottomAdjacent;
                            scrollPosition = PerformanceScrollPositionTop;
                            goOn = YES;
                            break;
                        case NextSystemPositionTopAdjacent:
                            scrollPosition = PerformanceScrollPositionMiddle;
                            goOn = NO;
                            break;
                        default:
                            if (APP_DEBUG) {
                                NSLog(@"Boxtype didn't match in systemdiff > 0 box one");
                            }
                            break;
                    }
                }else {
                    goOn = NO;
                    switch (systemPosition) {
                        case NextSystemPositionNone: // fall through
                        case NextSystemPositionBottomAdjacent:
                            scrollPosition = PerformanceScrollPositionTop;
                            break;
                        case NextSystemPositionTopAdjacent:
                            scrollPosition = PerformanceScrollPositionMiddle;
                            break;
                        default:
                            if (APP_DEBUG) {
                                NSLog(@"Boxtype didn't match in systemdiff > 0 box two or greater");
                            }
                            break;
                    }
                }
            }else {
                systemDiff *= -1; // flip the sign
                if (systemDiff < sameBox) {
                    continue;
                }else if (systemDiff < adjacentBox) {
                    switch (systemPosition) {
                        case NextSystemPositionNone: // fall through
                        case NextSystemPositionTopAdjacent:
                            systemPosition |= NextSystemPositionTopAdjacent;
                            scrollPosition = PerformanceScrollPositionMiddle;
                            goOn = YES;
                            break;
                        case NextSystemPositionBottomAdjacent:
                            scrollPosition = PerformanceScrollPositionMiddle;
                            goOn = NO;
                            break;
                        default:
                            if (APP_DEBUG) {
                                NSLog(@"Boxtype didn't match in systemdiff < 0 box one");
                            }
                            break;
                    }
                }else {
                    goOn = NO;
                    switch (systemPosition) {
                        case NextSystemPositionNone: // fall through
                        case NextSystemPositionTopAdjacent:
                            scrollPosition = PerformanceScrollPositionBottom;
                            break;
                        case NextSystemPositionBottomAdjacent:
                            scrollPosition = PerformanceScrollPositionMiddle;
                            break;
                        default:
#ifdef DEBUG
                            NSLog(@"Boxtype didn't match in systemdiff < 0 box two or greater");
#endif
                            break;
                    }
                }
            }
        }
        for (NSUInteger i = 0; i < system.count; i++) {
            [self.scrollPositions addObject:@(scrollPosition)];
        }
    }

    //NSLog(@"%@", self.scrollPositions);
}

- (CGFloat)scrollPositionBoxHeight
{
    // Should this be in page coordinate space?
    // i.e. CGRect visibleArea = [self.delegate scrollViewBoundsInPageCoordinates];
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(scrollViewBoundsInPageCoordinates)]) {
        CGRect visibleArea = [self.delegate scrollViewBoundsInPageCoordinates];
        return (visibleArea.size.height - 2 * kMinMeasureDistanceToEdge) / 3.0f;
    }else {
        return 0;
    }
}

#pragma mark - Score Duration Calculation

- (NSTimeInterval)performanceDuration
{
    NSTimeInterval duration = 0.0;
    
    [self createTimelineWithScrollPositions:NO];
    
    if (nil != self.timeline && [self.timeline count] > 0) {
        self.startMeasure = self.timeline[0];
        
        for (Measure *aMeasure in self.timeline) {
            duration += [aMeasure duration];
        }
    }
    
    return duration;
}

#pragma mark - Memory Management

- (void)dealloc
{
    if (!self.playtimeCalcOnly) {
        AudioComponentInstanceDispose(audioUnit);
        for(int i = 0; i < self.remoteContext->click->mNumberBuffers; i++) {
            free(self.remoteContext->click->mBuffers[i].mData);
        }
        free(self.remoteContext->click);
    }
    free(self.remoteContext);

    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


#pragma mark - Remote I/O

- (void)setupRemoteIO
{
    OSStatus status;   
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    //checkStatus(status);

    UInt32 flag = 1;
    
    // Enable IO for playback even though IO is enabled by default for the output
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO, 
                                  kAudioUnitScope_Output, 
                                  kOutputBus,
                                  &flag, 
                                  sizeof(flag));
#ifdef DEBUG
    CheckStatus(status, "Couldn't enable remote io output");
#endif
    
    // Apply format
    status = AudioUnitSetProperty(audioUnit, 
                                  kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Input, 
                                  kOutputBus, 
                                  &(self.remoteContext->clickDescription),
                                  sizeof(AudioStreamBasicDescription));
#ifdef DEBUG
    CheckStatus(status, "Couldn't set remote io stream format");
#endif
    
    // Set output callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = self.remoteContext;
    status = AudioUnitSetProperty(audioUnit, 
                                  kAudioUnitProperty_SetRenderCallback, 
                                  kAudioUnitScope_Global, 
                                  kOutputBus,
                                  &callbackStruct, 
                                  sizeof(callbackStruct));
#ifdef DEBUG
    CheckStatus(status, "Couldn't set remote io callback");
#endif
    
    // Disable buffer allocation for playback (optional - do this if we want to pass in our own)
//    flag = 0;
//    status = AudioUnitSetProperty(audioUnit, 
//                                  kAudioUnitProperty_ShouldAllocateBuffer,
//                                  kAudioUnitScope_Input, 
//                                  kOutputBus,
//                                  &flag, 
//                                  sizeof(flag));
//    
    
    // Initialise
    status = AudioUnitInitialize(audioUnit);
#ifdef DEBUG
    CheckStatus(status, "Couldn't initialize remote io audio unit");
#endif
}


static OSStatus playbackCallback(void *inRefCon, 
                                 AudioUnitRenderActionFlags *ioActionFlags, 
                                 const AudioTimeStamp *inTimeStamp, 
                                 UInt32 inBusNumber, 
                                 UInt32 inNumberFrames, 
                                 AudioBufferList *ioData) 
{    
    RemoteContext *remoteContext = inRefCon;
    UInt64 now = mach_absolute_time();
    
    UInt64 countInIndex = (remoteContext->countInPtr - remoteContext->countInTimeline);
    if (remoteContext->countIn && 
        countInIndex < remoteContext->countInTimelineLength &&
        now > (*(remoteContext->countInPtr) + remoteContext->mach_start_time))
    {
        [remoteContext->performanceManager performSelectorOnMainThread:@selector(updateCountInView)
                                                            withObject:nil
                                                         waitUntilDone:NO];
        if (remoteContext->visualMetronome) {
            [remoteContext->performanceManager performSelectorOnMainThread:@selector(visualClick)
                                                                withObject:nil
                                                             waitUntilDone:NO];
        }

        remoteContext->currentClickFrame = 0;
        remoteContext->countInPtr++;
    }
    
    UInt64 measureIndex = (remoteContext->measurePtr - remoteContext->measureTimeline);
    if (measureIndex < remoteContext->measureTimelineLength &&
        now > (*(remoteContext->measurePtr) + remoteContext->mach_start_time))
    {
        [remoteContext->performanceManager performSelectorOnMainThread:@selector(showNextMeasure)
                                                            withObject:nil
                                                         waitUntilDone:NO];
        remoteContext->measurePtr++;
    }
    
    UInt64 clickIndex = (remoteContext->clickPtr - remoteContext->clickTimeline);
    if (clickIndex < remoteContext->clickTimelineLength &&
        now > (*(remoteContext->clickPtr) + remoteContext->mach_start_time))
    {
        if (remoteContext->visualMetronome) {
            [remoteContext->performanceManager performSelectorOnMainThread:@selector(visualClick)
                                                                withObject:nil
                                                             waitUntilDone:NO];
        }
        if (0 == clickIndex) {
            [remoteContext->performanceManager performSelectorOnMainThread:@selector(showCurrentMeasure)
                                                                withObject:nil
                                                             waitUntilDone:NO];
        }
        
        remoteContext->currentClickFrame = 0;
        remoteContext->clickPtr++;
    }
    
    UInt32 bytesPerFrame = remoteContext->clickDescription.mBytesPerFrame;
    UInt64 currentClickFrame = remoteContext->currentClickFrame;
    
    // Two channels interleaved
#if 2 == kNumberOfChannels
    SInt32 *sourceBuffer = remoteContext->click->mBuffers[0].mData;
    SInt32 *targetBuffer = (SInt32 *)ioData->mBuffers[0].mData;
#else
    SInt16 *sourceBuffer = remoteContext->click->mBuffers[0].mData;
    SInt16 *targetBuffer = (SInt16 *)ioData->mBuffers[0].mData;
#endif
    
    SInt64 clickFramesRemaining = remoteContext->clickLengthFrames - currentClickFrame;
    if (clickFramesRemaining > 0 && remoteContext->metronomeAudible) {
        if (clickFramesRemaining < inNumberFrames) {
            memcpy(targetBuffer, &sourceBuffer[currentClickFrame], clickFramesRemaining * bytesPerFrame);
            memset(targetBuffer + clickFramesRemaining, 0, (inNumberFrames - clickFramesRemaining) * bytesPerFrame);
            remoteContext->currentClickFrame += clickFramesRemaining;
        }else {
            memcpy(targetBuffer, &sourceBuffer[currentClickFrame], inNumberFrames * bytesPerFrame) ;
            remoteContext->currentClickFrame += inNumberFrames;
        }  
    }else {
        memset(targetBuffer, 0, inNumberFrames * bytesPerFrame);
    }
    return noErr;
}

void loadClickData(RemoteContext *remoteContext)
{
    AudioStreamBasicDescription streamDescription = remoteContext->clickDescription;
    OSStatus status = noErr;
    CFURLRef clickFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                          (__bridge CFStringRef)[[NSBundle mainBundle] pathForResource:@"clave"
                                                                                                                ofType:@"wav"],
                                                          kCFURLPOSIXPathStyle,
                                                          false);
    
	ExtAudioFileRef extAudioFile;
	status = ExtAudioFileOpenURL(clickFileURL, &extAudioFile);
    if (APP_DEBUG) {
        CheckStatus(status, "Error opening file");
    }
    
	// tell extAudioFile about our format
	status = ExtAudioFileSetProperty(extAudioFile,
                                     kExtAudioFileProperty_ClientDataFormat,
                                     sizeof (AudioStreamBasicDescription),
                                     &streamDescription);
    if (APP_DEBUG) {
        CheckStatus(status, "Error setting file properties");
    }
	// figure out how big a buffer we need
	SInt64 fileLengthFrames;
	UInt32 propSize = sizeof (fileLengthFrames);
	status = ExtAudioFileGetProperty(extAudioFile,
                                     kExtAudioFileProperty_FileLengthFrames,
                                     &propSize,
                                     &fileLengthFrames);
    if (APP_DEBUG) {
        CheckStatus(status, "Error getting file properties");
        NSLog(@"plan on reading %lld frames\n", fileLengthFrames);
    }
    
	SInt64 fileLengthBytes = fileLengthFrames * streamDescription.mBytesPerFrame;
    remoteContext->clickLengthFrames = (UInt64) fileLengthFrames;
    
    UInt32 ablSize = offsetof(AudioBufferList, mBuffers[0]) + sizeof(AudioBuffer);
	AudioBufferList *bufferList = malloc(ablSize);
    bufferList->mNumberBuffers = 1;
    
#if 2 == kNumberOfChannels
    SInt32 *audioDataPtr =  (SInt32 *) malloc(fileLengthBytes);
#else
    SInt16 *audioDataPtr =  (SInt16 *) malloc(fileLengthBytes);
#endif
    bufferList->mBuffers[0].mNumberChannels = kNumberOfChannels;
    bufferList->mBuffers[0].mDataByteSize = fileLengthBytes;
    bufferList->mBuffers[0].mData = audioDataPtr;
    
    // loop reading into the ABL until buffer is full
#if 2 == kNumberOfChannels
    SInt32 totalFramesRead = 0;
#else
    SInt16 totalFramesRead = 0;
#endif
    do {
        UInt32 framesRead = fileLengthFrames - totalFramesRead;
        bufferList->mBuffers[0].mData = (audioDataPtr + totalFramesRead);
        bufferList->mBuffers[0].mDataByteSize = framesRead * streamDescription.mBytesPerFrame;
        status = ExtAudioFileRead(extAudioFile,
                                  &framesRead,
                                  bufferList);
        totalFramesRead += framesRead;
#ifdef DEBUG
        CheckStatus(status, "Error reading audio packets");
        NSLog (@"read %lu frames\n", framesRead);
#endif
    } while (totalFramesRead < fileLengthFrames);
    
    bufferList->mBuffers[0].mData = audioDataPtr;
    bufferList->mBuffers[0].mDataByteSize = fileLengthBytes;
    
    remoteContext->click = bufferList;
}

void CheckStatus(OSStatus status, const char *operation)
{
	if (status == noErr) return;
	
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(status);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)status);
    
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
}

void printASBD(AudioStreamBasicDescription asbd) {
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10lu",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10lu",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10lu",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10lu",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10lu",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10lu",    asbd.mBitsPerChannel);
   
}

#pragma mark - Audio Session Interruption Listener
/*
void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
	OSStatus status = noErr;
	PerformanceManager *THIS = (PerformanceManager *)inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		status = AudioSessionSetActive(true);
#ifdef DEBUG
        CheckStatus(status, "couldn't set audio session active");
#endif
		status = AudioOutputUnitStart(THIS.audioUnit);
#ifdef DEBUG
        CheckStatus(status, "couldn't start unit");
#endif
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
		status = AudioOutputUnitStop(THIS.audioUnit);
#ifdef DEBUG
        CheckStatus(status, "couldn't stop unit");
#endif
    }
}
 */

/*
 #pragma mark - Audio Session Delegate
 
 - (void)beginInterruption
 {
 [self.delegate stop];  // removes measure highlight and calls stop on peformance mananger
 #ifdef DEBUG
 NSLog(@"%s %d", __FUNCTION__, __LINE__);
 #endif
 }
 */

@end
