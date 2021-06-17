//
//  PerformanceViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerformanceViewController.h"
#import "PerformanceManager.h"
#import "ScrollSpeedSelectorViewController.h"


@class EditorViewController;
@class CountInView;
@class AirTurnBpmView;
@class TempoToolbarView;

@interface PerformanceScrollingViewController : PerformanceViewController <UIScrollViewDelegate,
        PerformanceManagerDelegate, UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) PerformanceManager *performanceManager;
@property (nonatomic, strong) IBOutlet CountInView *countInView;
@property (nonatomic, strong) IBOutlet TempoToolbarView *tempoToolbarView;
@property (nonatomic, strong) UIPopoverPresentationController *tempoSelectPresentationController,
*enterMeasurePresentationController;
@property (nonatomic, strong) UIBarButtonItem *tempoItem, *chooseStartMeasureItem, *rewindButton, *stopItem, *playButton,
        *pauseButton;
@property (nonatomic, strong) UITapGestureRecognizer *pagePickerDismisser;
@property (nonatomic, strong) UILongPressGestureRecognizer *startMeasureRecognizer;
@property (nonatomic, assign) CGPoint scrollToPoint;
@property (nonatomic, strong) IBOutlet UIImageView *visualMetronomeView;
@property (nonatomic, strong) IBOutlet AirTurnBpmView *airTurnBpmView;
@property (nonatomic, strong) UIImageView *activeMeasureIndicator, *startMeasureIndicator;
@property (nonatomic, strong) ScrollSpeedSelectorViewController *scrollSpeedSelectorViewController;
@property (nonatomic, strong) UIView *pageHostingView;
@property (nonatomic, assign) BOOL canvasDidSetup;

- (id)initWithSet:(Set *)theSet
            score:(Score *)theScore
             page:(Page *)thePage
  performanceMode:(PerformanceMode)thePerformanceMode;

- (void)highlightMeasureAtPoint:(CGPoint)point;
- (void)removeMeasureHighlight;
- (void)highlightStartMeasure;
- (void)showEnterMeasurePrompt;
- (void)play;
- (void)pause;
- (void)stop;
- (void)rewind;
- (CGRect)targetZoneRectForScrollPosition:(PerformanceScrollPosition)scrollPosition;
- (CGRect)scrollViewBoundsInPageCoordinates;
- (void)prepareCountInView;
- (void)removeCountInView;
- (void)updateCountInViewWithBeat:(NSNumber *)beat;
- (void)finishCountIn;
- (CGRect)contentFrame;

#define kFinishedPerformanceViewWidth 250.0f
#define kFinishedPerformanceViewHeight 150.0f
#define kMetronomeFormatString @"= %d"
#define kMeasureIndicatorAlpha .7
@end
