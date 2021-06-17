//
//  Helpers.h
//  ScoreScroll
//
//  Created by Moritz Pfeiffer on 06.11.09.
//  Copyright 2009 Alp Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helpers : NSObject

typedef enum {
    NoteValueImageSpecifierWhite = 857,
    NoteValueImageSpecifierBlack,
    NoteValueImageSpecifierPetrol
} NoteValueImageSpecifier;

typedef enum {
    SignAnnotationCategoryArticulations,
    SignAnnotationCategoryFingerings,
    SignAnnotationCategoryDynamics,
    SignAnnotationCategoryOrnaments
} SignAnnotationCategoryType;


+ (Helpers *)sharedInstance;

+ (void)configureAppearances;

+ (void)printFrame:(CGRect)frame description:(NSString *)description;
+ (void)printSize:(CGSize)size description:(NSString *)description;
+ (void)printPoint:(CGPoint)point description:(NSString *)description;

// Dates
+ (NSString *)shortDateFormat;
+ (NSString *)dbDateFormat;
+ (NSString *)formatDateShort:(NSDate *)date;
+ (NSArray *)arrayWithSortDescriptorForTableView;

// Gesture Recognizers
+ (UITapGestureRecognizer *)singleFingerTabRecognizerwithTarget:(id)target 
                                                         action:(SEL)action
                                                       delegate:(id <UIGestureRecognizerDelegate>)delegate;

// Toolbar items
+ (UIBarButtonItem *)flexibleSpaceItem;
+ (UIBarButtonItem *)fixedSpaceItem:(CGFloat)width;

+ (NSArray *)noteValues;
+ (NSArray *)bpmValues;
+ (NSArray *)metronomeTicks;

+ (NSArray *)timeSignatureNumeratorValues;
+ (NSArray *)timesignatureDenominatorValues;

+ (double)doubleValueForTimeDenominator:(NSNumber *)denominator;
+ (double)doubleValueForNoteValue:(NSString *)noteValue;
+ (UIImage *)noteValueImageForTimeDenominator:(NSNumber *)denominator 
                               imageSpecifier:(NoteValueImageSpecifier)specifier;
+ (UIImage *)noteValueImageForNoteValueString:(NSString *)noteValue 
                               imageSpecifier:(NoteValueImageSpecifier)specifier;

// Translation
+ (NSString *)localizedPerformanceModeStringForMode:(PerformanceMode)theMode;
+ (NSString *)eventTrackingStringForPerformanceMode:(PerformanceMode)theMode;
+ (NSString *)viewTrackingStringForPerformanceMode:(PerformanceMode)theMode;
+ (NSString *)trackingStringForEditorType:(EditorViewControllerType)theType;
+ (NSString *)localizedEditorTypeStringForType:(EditorViewControllerType)theType;
+ (NSSet *)doneBarButtonPossibleTitles;
+ (NSSet *)penBarButtonPossibleTitles;

+ (NSURL *)localizedTutorialMovieUrlForTutorialType:(TutorialType)theType;
+ (NSString *)localizedTutorialDescriptionForTutorialType:(TutorialType)theType;
+ (NSString *)localizedTutorialTitleForTutorialType:(TutorialType)theType;
+ (UIImage *)splashImageForTutorialType:(TutorialType)theType;
+ (NSString *)localizedPerformanceScrollPositionName:(PerformanceScrollPosition)position;

// Design
+ (UIColor*)centralViewBrown;
+ (UIColor *)babyBlue;
+ (UIColor *)darkerBabyBlue;
+ (UIColor *)labelBlue;
+ (UIImage*)helperArrowDown;
+ (UIColor *)measureHighlightColor;


#pragma mark - New Colors
+ (UIColor *)grey;
+ (UIColor *)lightGrey;
+ (UIColor *)black;
+ (UIColor *)petrol;
+ (UIColor *)lightPetrol;
+ (UIColor *)lightBlue;
+ (UIColor *)darkYellow;
+ (UIColor *)yellow;
+ (UIColor *)lightYellow;
+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIColor *)red;

// Fonts
+ (UIFont*)avenirNextRegularFontWithSize:(CGFloat)size;
+ (UIFont*)avenirNextMediumFontWithSize:(CGFloat)size;
+ (UIFont*)avenirNextCondensedDemiBoldFontWithSize:(CGFloat)size;

+ (NSArray*)signAnnotationCategoryKeys;
+ (NSString*)signAnnotationCategoryNameForKey:(NSString*)categoryKey;
+ (NSArray*)signAnnotationKeysForCategory:(NSString*)categoryKey;
+ (NSString*)signAnnotationCategoryForSignAnnotation:(NSString*)signAnnotationKey;

+ (NSArray*)annotationColors;
+ (NSArray*)annotationColorNames;

int equalsd (double a, double b);
int equalsf (float a, float b);

// Buttons
+ (UIBarButtonItem*)doneBarButtonItemWithTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem*)shareBarButtonItemWithTarget:(id)target action:(SEL)action;

// UIAlertController
+ (UIAlertController*)maxScoresReachedAlerController;
+ (UIAlertController*)alertControllerWithTitle:(NSString*)title message:(NSString*)message;

// File Operations
+ (BOOL)verifyPdfFile:(NSString *)pdfFilePath;
+ (BOOL)removeFileAtPath:(NSString*)filePath;

@end
