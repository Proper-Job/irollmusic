//
//  SleepManager.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepManager : NSObject

@property (nonatomic, strong) NSMutableSet *insomniacs;

+ (SleepManager *)sharedInstance;
- (void)addInsomniac:(id)insomniac;
- (void)removeInsomniac:(id)insomniac;
@end
