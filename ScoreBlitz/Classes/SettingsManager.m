//
//  SettingsManager.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 14.02.11.
//  Copyright 2011 Moritz Pfeiffer. All rights reserved.
//

#import "SettingsManager.h"
#import "AnnotationPen.h"
#import "ScoreBlitzAppDelegate.h"
#import "CentralViewController.h"

@implementation SettingsManager

static NSBundle *bundle = nil;

#pragma mark -
#pragma mark Methods ensuring singleton status

+ (SettingsManager *)sharedInstance
{
    static SettingsManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark -
#pragma mark Register Application Defaults


+ (void)initialize
{
	if ([self class] == [SettingsManager class]) {
		
		// Register Application Defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // setup language
        NSString *systemLanguage;
        NSString *appLanguage = kEnglishLanguage;
        @try {
            systemLanguage = [[defaults objectForKey:kAppleLanguages] objectAtIndex:0];
#ifdef DEBUG
            NSLog(@"System language: %@", systemLanguage);
#endif
            if ([[SettingsManager supportedLocalizations] containsObject:systemLanguage]) {
                appLanguage = systemLanguage;
            }
        }
        @catch (NSException *exception) {
#ifdef DEBUG
            NSLog(@"Caught exception while getting system language");
#endif
        }
        
		NSMutableDictionary *applicationDefaults = [NSMutableDictionary dictionary];
        [applicationDefaults setObject:[NSNumber numberWithBool:YES] forKey:kShowHelpers];
        [applicationDefaults setObject:[NSNumber numberWithInt:kAnnotationStandardPenColor]  forKey:kAnnotationPenColor];
        [applicationDefaults setObject:[NSNumber numberWithInt:kAnnotationStandardPenLineWidth]  forKey:kAnnotationPenLineWidth];
        [applicationDefaults setObject:[NSNumber numberWithFloat:kAnnotationStandardPenAlpha]  forKey:kAnnotationPenAlpha];
        [applicationDefaults setObject:appLanguage forKey:kAppLanguage];
        [applicationDefaults setObject:@"" forKey:kFeedBackText];
        [applicationDefaults setObject:[NSNumber numberWithBool:YES] forKey:kSettingSimpleModeScrollsContinuously];
        [applicationDefaults setObject:[NSNumber numberWithBool:YES] forKey:kSettingEnablePagingTapZones];
        [applicationDefaults setObject:[NSNumber numberWithBool:YES] forKey:kSettingPagingTapZoneFlashPageNumber];
        [applicationDefaults setObject:[NSNumber numberWithBool:YES] forKey:kFirstBootFlag];
        [applicationDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDidMigrateMeasureToVersionOnePointOne];
        [applicationDefaults setObject:[NSNumber numberWithInt:-1] forKey:kLastTutorialMovieViewed];
        [applicationDefaults setObject:[NSNumber numberWithInt:1] forKey:kMetronomeCountInNumberOfBars];
        [applicationDefaults setObject:[NSNumber numberWithBool:YES] forKey:kMetronomeAudible];
        [applicationDefaults setObject:[NSNumber numberWithInt:PerformanceScrollPositionAutomatic] forKey:kSettingScrollPosition];
        [applicationDefaults setObject:[NSArray array] forKey:kRecentSignAnnotations];
        [applicationDefaults setObject:[NSNumber numberWithBool:NO] forKey:kVisualMetronome];
        [applicationDefaults setObject:[NSNumber numberWithBool:YES] forKey:kSettingRollByMeasureShowArrow];
		[defaults registerDefaults:applicationDefaults];
		[defaults synchronize];	
        
        [SettingsManager setLanguage:[defaults objectForKey:kAppLanguage]];
	}
}

#pragma - Translations

+ (NSArray *)supportedLocalizations
{
    return [NSArray arrayWithObjects:
              kEnglishLanguage,
              kGermanLanguage,
              kSpanishLanguage,
              kFrenchLanguage,
              kChineseSimplifiedLanguage,
              nil];
}


+ (NSString *)language
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppLanguage];
}

+ (NSLocale*)localeIdentifier
{
    NSString *localeIdentifier;
    NSString *languageIdentifier = [SettingsManager language];
    if ([languageIdentifier isEqualToString:kEnglishLanguage]) {
        localeIdentifier = [NSString stringWithFormat:@"%@_GB", kEnglishLanguage];
    } else if ([languageIdentifier isEqualToString:kGermanLanguage]) {
        localeIdentifier = [NSString stringWithFormat:@"%@_DE", kGermanLanguage];
    } else if ([languageIdentifier isEqualToString:kFrenchLanguage]) {
        localeIdentifier = [NSString stringWithFormat:@"%@_FR", kFrenchLanguage];
    } else if ([languageIdentifier isEqualToString:kSpanishLanguage]) {
        localeIdentifier = [NSString stringWithFormat:@"%@_ES", kSpanishLanguage];
    } else if ([languageIdentifier isEqualToString:kChineseSimplifiedLanguage]) {
        localeIdentifier = [NSString stringWithFormat:@"%@_CN", kChineseSimplifiedLanguage];
    }
    return [NSLocale localeWithLocaleIdentifier:localeIdentifier];
}

+ (void)setLanguage:(NSString *)language 
{
#ifdef DEBUG
    NSLog(@"preferredLang: %@", language);
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:language forKey:kAppLanguage];
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    bundle = [NSBundle bundleWithPath:path];
    
    [defaults setObject:[NSArray arrayWithObject:language] forKey:kAppleLanguages];
    [defaults synchronize];
    
    // send message to active view controllers
    [[NSNotificationCenter defaultCenter] postNotificationName:kLanguageChanged object:self];
}

+ (NSString *)getLocalizedStringForKey:(NSString *)key alternateValue:(NSString *)alternate
{
    NSString *retVal = [bundle localizedStringForKey:key value:alternate table:nil];
    if (nil == retVal) {
        return [NSString string];
    }else {
        return retVal;
    }
}

#pragma mark -
#pragma mark Defaults Accessors

- (NSString*)feedbackText
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFeedBackText];
}

- (void)setFeedbackText:(NSString*)text
{
#ifdef DEBUG
    NSLog(@"SettingsManager: setFeedbackText: FeedbackText: %@", text);
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:text forKey:kFeedBackText];
    [defaults synchronize];
}

- (NSArray*)recentSignAnnotations
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *signAnnotations = [defaults valueForKey:kRecentSignAnnotations];
    return signAnnotations;
}

- (void)pushSignAnnotationKeyToRecentSignAnnotations:(NSString*)signAnnotationKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *signAnnotations = [NSMutableArray arrayWithArray:[defaults valueForKey:kRecentSignAnnotations]];
    
    if ([signAnnotations containsObject:signAnnotationKey]) {
        [signAnnotations removeObject:signAnnotationKey];
        [signAnnotations insertObject:signAnnotationKey atIndex:0];
    } else if ([signAnnotations count] >= kMaxRecentSignAnnotations) {
        [signAnnotations removeLastObject];
        [signAnnotations insertObject:signAnnotationKey atIndex:0];
    } else {
        [signAnnotations insertObject:signAnnotationKey atIndex:0];
    }
    
    NSArray *newSignAnnotations = [NSArray arrayWithArray:signAnnotations];
    [defaults setValue:newSignAnnotations forKey:kRecentSignAnnotations];
    
    [defaults synchronize];    
}
@end
