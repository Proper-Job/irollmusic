//
//  GoogleAnalyticsManager.m
//  TagesWoche
//
//  Created by Max Pfeiffer on 01.11.12.
//
//

#import "TrackingManager.h"

@implementation TrackingManager

+ (TrackingManager *)sharedInstance
{
    static TrackingManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    return self;
}

- (NSString *)googleTrackingId
{
    return kGoogleAnalyticsAccountId;    
}

- (void)trackGoogleEventWithCategoryString:(NSString*)categoryString
                              actionString:(NSString*)actionString
                               labelString:(NSString*)labelString
                               valueNumber:(NSNumber*)valueNumber
{
    return;
}

- (void)trackGoogleViewWithIdentifier:(NSString*)identifier
{
    return;
}

@end
