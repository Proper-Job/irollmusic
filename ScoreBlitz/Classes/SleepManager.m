//
//  SleepManager.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SleepManager.h"

@implementation SleepManager

@synthesize insomniacs;

#pragma mark - Methods ensuring singleton status

+ (SleepManager *)sharedInstance
{
    static SleepManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
        insomniacs = [[NSMutableSet alloc] init];
	}
	return self;
}


- (void)addInsomniac:(id)insomniac
{
    @synchronized(self) {
        if (nil != insomniac && ![self.insomniacs containsObject:insomniac]) {
#ifdef DEBUG
            NSLog(@"%@ registered with SleepManager as an insomniac", [insomniac description]);
#endif
            [self.insomniacs addObject:insomniac];
        }
        
        if ([self.insomniacs count] > 0) {
#ifdef DEBUG
            NSLog(@"%d insomniac(s) hanging out without any sleep. Disabling idle timer.", [self.insomniacs count]);
#endif
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        }
    }
}

- (void)removeInsomniac:(id)insomniac
{
    @synchronized(self) {
        if (nil != insomniac && [self.insomniacs containsObject:insomniac]) {
            [self.insomniacs removeObject:insomniac];
#ifdef DEBUG
            NSLog(@"%@ is trying to catch some sleep and asked the SleepManager to be removed.", [insomniac description]);
#endif
        }
        
        if (0 == [self.insomniacs count]) {
#ifdef DEBUG
            NSLog(@"No more insomniacs hanging out.  Enabling idle timer");
#endif
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }else {
#ifdef DEBUG
            NSLog(@"%d insomniac(s) is/are still kicking it", [self.insomniacs count]);
#endif
        }
    }
}

@end
