//
//  GoogleAnalyticsManager.h
//  TagesWoche
//
//  Created by Max Pfeiffer on 01.11.12.
//
//

#import <Foundation/Foundation.h>

@interface TrackingManager : NSObject
+ (TrackingManager *)sharedInstance;
- (void)trackGoogleEventWithCategoryString:(NSString*)categoryString actionString:(NSString*)actionString labelString:(NSString*)labelString valueNumber:(NSNumber*)valueNumber;
- (void)trackGoogleViewWithIdentifier:(NSString*)identifier;
@end
