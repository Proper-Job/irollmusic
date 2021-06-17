//
//  SettingsManager.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsManager : NSObject {


}
+ (SettingsManager *)sharedInstance;
+ (NSArray *)supportedLocalizations;
+ (void)setLanguage:(NSString *)language; 
+ (NSString *)language;
+ (NSLocale*)localeIdentifier;
+ (NSString *)getLocalizedStringForKey:(NSString *)key alternateValue:(NSString *)alternate;

- (NSString*)feedbackText;
- (void)setFeedbackText:(NSString*)text;
- (NSArray*)recentSignAnnotations;
- (void)pushSignAnnotationKeyToRecentSignAnnotations:(NSString*)signAnnotationKey;

@end
