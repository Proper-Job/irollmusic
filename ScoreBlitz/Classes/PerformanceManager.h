//
//  ScrollingManager.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class Score, Measure, PerformanceManager;
@class PerformanceScrollingViewController;

typedef struct {
    bool metronomeAudible;
    bool visualMetronome;
    bool audioUnitRunning;
    bool countIn;
    double timebase_ratio;
    UInt64 mach_start_time;
    UInt64 *countInTimeline;
    UInt64 countInTimelineLength;
    UInt64 *countInPtr;
    UInt64 *measureTimeline;
    UInt64 measureTimelineLength;
    UInt64 *measurePtr;
    UInt64 *clickTimeline;
    UInt64 clickTimelineLength;
    UInt64 *clickPtr;
    UInt64 clickLengthFrames;
    UInt64 currentClickFrame;
    AudioBufferList *click;
    AudioStreamBasicDescription clickDescription;
    __unsafe_unretained PerformanceManager *performanceManager;
} RemoteContext;

#define kSampleRate 44100.0
#define kNumberOfChannels 1
#define bitDepthBytes sizeof(SInt16)
#define kOutputBus 0
#define kInputBus 1

@interface PerformanceManager : NSObject {
    AudioComponentInstance audioUnit;
}

@property (nonatomic, weak) PerformanceScrollingViewController *delegate;
@property (nonatomic, assign) PerformanceMode performanceMode;
@property (nonatomic, strong) NSMutableArray *timeline;
@property (nonatomic, strong) Measure *activeMeasure, *startMeasure;
@property (nonatomic, strong) Score *activeScore;
@property (nonatomic, assign) BOOL continuousScroll, playtimeCalcOnly;
@property (nonatomic, assign) NSUInteger playbackIndex;
@property (nonatomic, assign) CGFloat canvasHeight;

- (id)initWithScore:(Score *)score 
           delegate:(id)theDelegate
    performanceMode:(PerformanceMode)theMode
playtimeCalculationOnly:(BOOL)playtimeOnly;

- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
- (CGPoint)measurePositionOnCanvas:(Measure *)measure;
- (void)createTimelineWithScrollPositions:(BOOL)createScrollPositions;
- (NSTimeInterval)performanceDuration;
- (void)airTurnEvent;

#define kOneSecond 1.0
#define kContinuousScrollAnimationDuration 0.25
#define kStartTimerFlag @"StartTimerFlag"
#define kMinMeasureDistanceToEdge roundf(50.0f + kMeasureMarkerViewHeight / 2.0f)
#define kCountInContextNumberOfBeats @"CountInContextNumberOfBeats"
#define kCountInContextNumberOfBars @"CountInContextNumberOfBars"


enum {
    NextSystemPositionNone              = 0,       // 0
    NextSystemPositionBottomAdjacent    = 1 << 0,  // 1
    NextSystemPositionTopAdjacent       = 1 << 1,  // 2
};
typedef NSUInteger NextSystemPosition;

@end

@protocol PerformanceManagerDelegate
- (void)scrollToMeasureAtPoint:(CGPoint)point 
                      animated:(BOOL)animated 
                scrollPosition:(PerformanceScrollPosition)scrollPosition;
- (void)scrollToPoint:(CGPoint)point;
- (void)highlightMeasureAtPoint:(CGPoint)point;
- (void)finishedPlayback;
- (void)finishedSimplePlayback;
- (void)showVisualClick;
@end