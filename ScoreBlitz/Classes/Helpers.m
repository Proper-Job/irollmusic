//
//  Helpers.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 06.11.09.
//  Copyright 2009 Alp Phone. All rights reserved.
//

#import "CentralViewController.h"
#import "UIImage+Overlay.h"
#import "MeasureEditorView.h"
#import "MultipleMeasureEditorViewController.h"
#import "MultipleBpmEditorViewController.h"
#import "AnnotationsStylePopoverViewController.h"

#pragma mark - Methods ensuring singleton status

@implementation Helpers

+ (Helpers *)sharedInstance
{
    static Helpers *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (void)configureAppearances
{
    // NavigationBar
    NSMutableDictionary *navigationBarTitleAttributes = [@{
            NSForegroundColorAttributeName: [Helpers petrol],
            NSFontAttributeName: [Helpers avenirNextMediumFontWithSize:24]

    } mutableCopy];
    [[UINavigationBar appearance] setTintColor:[Helpers petrol]];
    [[UINavigationBar appearance] setTitleTextAttributes:navigationBarTitleAttributes];

    [navigationBarTitleAttributes setValue:[Helpers avenirNextMediumFontWithSize:18]
                                    forKey:NSFontAttributeName];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[UIPopoverController class]]] setTitleTextAttributes:navigationBarTitleAttributes];
    
    // Labels in toolbars
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class]]] setTextColor:[Helpers petrol]];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class]]] setFont:[Helpers avenirNextMediumFontWithSize:18]];
    
    // Toolbar
    [[UIToolbar appearanceWhenContainedInInstancesOfClasses:@[[CentralViewController class]]] setBarTintColor:[UIColor blackColor]];
    
    // Bar Buttons
    [[UIBarButtonItem appearance] setTintColor:[Helpers petrol]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [CentralViewController class]]] setTintColor:[UIColor whiteColor]];
    
    NSMutableDictionary *buttonTextAttributes = [[NSMutableDictionary alloc] init];
    [buttonTextAttributes setValue:[Helpers petrol] forKey:NSForegroundColorAttributeName];
    [buttonTextAttributes setValue:[Helpers avenirNextMediumFontWithSize:18] forKey:NSFontAttributeName];
    [[UIBarButtonItem appearance] setTitleTextAttributes: buttonTextAttributes forState: UIControlStateNormal];

    NSMutableDictionary *centralViewButtonTextAttributes = [[NSMutableDictionary alloc] init];
    [centralViewButtonTextAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [centralViewButtonTextAttributes setValue:[Helpers avenirNextMediumFontWithSize:18] forKey:NSFontAttributeName];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [CentralViewController class]]] setTitleTextAttributes: centralViewButtonTextAttributes forState: UIControlStateNormal];

    // UISwitch
    [[UISwitch appearance] setTintColor:[Helpers petrol]];
    [[UISwitch appearance] setOnTintColor:[Helpers petrol]];
    
    // UISegmentedControl
    [[UISegmentedControl appearance] setTintColor:[Helpers petrol]];
    NSMutableDictionary *segmentedControlTextAttributes = [[NSMutableDictionary alloc] init];
    [segmentedControlTextAttributes setValue:[Helpers petrol] forKey:NSForegroundColorAttributeName];
    [segmentedControlTextAttributes setValue:[Helpers avenirNextCondensedDemiBoldFontWithSize:18] forKey:NSFontAttributeName];
    [[UISegmentedControl appearance] setTitleTextAttributes:segmentedControlTextAttributes forState:UIControlStateNormal];

    // Editor
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[MeasureEditorView class], [MultipleMeasureEditorViewController class], [MultipleBpmEditorViewController class], [AnnotationsStylePopoverViewController class]]]
            setTextColor:[Helpers petrol]];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[MeasureEditorView class], [MultipleMeasureEditorViewController class], [MultipleBpmEditorViewController class], [AnnotationsStylePopoverViewController class]]]
            setFont:[Helpers avenirNextMediumFontWithSize:18]];
}


#pragma mark - Static helper methods

+ (void)printFrame:(CGRect)frame description:(NSString *)description
{
	NSLog(@"%@: x:%f y:%f width:%f height:%f", description, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

+ (void)printSize:(CGSize)size description:(NSString *)description
{
	NSLog(@"%@: width:%f height:%f", description, size.width, size.height);
}

+ (void)printPoint:(CGPoint)point description:(NSString *)description
{
	NSLog(@"\n%@:\nx:%f\ny:%f\n\n", description, point.x, point.y);
}

+ (NSString *)shortDateFormat {
	return @"dd.MM.y";
}

+ (NSString *)dbDateFormat {
	return @"yyyy-MM-dd-HH-mm-ss";
}
	

+ (NSString *)formatDateShort:(NSDate *)date {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:[Helpers shortDateFormat]];
	NSString *retVal = [formatter stringFromDate:date];
	return retVal;
}

+ (NSArray *)arrayWithSortDescriptorForTableView
{
	NSArray *arrayWithSortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
	return arrayWithSortDescriptor;
}

+ (UITapGestureRecognizer *)singleFingerTabRecognizerwithTarget:(id)target 
                                                         action:(SEL)action
                                                       delegate:(id <UIGestureRecognizerDelegate>)delegate
{
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    tapGesture.delegate = delegate;
	tapGesture.numberOfTouchesRequired = 1; // One finger
	tapGesture.numberOfTapsRequired = 1; // Single tap
	return tapGesture;
}



+ (UIBarButtonItem *)flexibleSpaceItem
{
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	return flexItem;
}

+ (UIBarButtonItem *)fixedSpaceItem:(CGFloat)width
{
    UIBarButtonItem *fixedWidthItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                              target:nil
                                                                              action:nil];
    fixedWidthItem.width = width;
    return fixedWidthItem;
}

+ (NSArray *)noteValues
{
    return @[
            kWholeNote,
            kDottedHalfNote,
            kHalfNote,
            kDottedQuarterNote,
            kQuarterNote,
            kDottedEigthNote,
            kEigthNote,
            kSixteenthNote
    ];
}

+ (NSArray *)bpmValues
{
    NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:240];
    
    for (int i = -120; i <= 120; i++) {
        [values addObject:@(i)];
    }
    
    return values;
}

+ (NSArray *)metronomeTicks
{
    NSMutableArray *ticks = [[NSMutableArray alloc] initWithCapacity:168];
    for (int i = 40; i <= 208; i++) {
        [ticks addObject:@(i)];
    }
    
    return ticks;
}

/*
+ (NSArray *)metronomeTicks
{
    return [[[NSArray arrayWithObjects:
              [NSNumber numberWithInt:40],
              [NSNumber numberWithInt:42],
              [NSNumber numberWithInt:44],
              [NSNumber numberWithInt:46],
              [NSNumber numberWithInt:48],
              [NSNumber numberWithInt:50],
              [NSNumber numberWithInt:52],
              [NSNumber numberWithInt:54],
              [NSNumber numberWithInt:56],
              [NSNumber numberWithInt:58],
              [NSNumber numberWithInt:60],
              [NSNumber numberWithInt:63],
              [NSNumber numberWithInt:69],
              [NSNumber numberWithInt:72],
              [NSNumber numberWithInt:76],
              [NSNumber numberWithInt:80],
              [NSNumber numberWithInt:84],
              [NSNumber numberWithInt:88],
              [NSNumber numberWithInt:92],
              [NSNumber numberWithInt:96],
              [NSNumber numberWithInt:100],
              [NSNumber numberWithInt:104],
              [NSNumber numberWithInt:108],
              [NSNumber numberWithInt:112],
              [NSNumber numberWithInt:116],
              [NSNumber numberWithInt:120],
              [NSNumber numberWithInt:126],
              [NSNumber numberWithInt:132],
              [NSNumber numberWithInt:138],
              [NSNumber numberWithInt:144],
              [NSNumber numberWithInt:152],
              [NSNumber numberWithInt:160],
              [NSNumber numberWithInt:168],
              [NSNumber numberWithInt:176],
              [NSNumber numberWithInt:184],
              [NSNumber numberWithInt:192],
              [NSNumber numberWithInt:200],
              [NSNumber numberWithInt:208], nil] retain] autorelease];
}
*/

+ (NSArray *)timeSignatureNumeratorValues
{
    NSMutableArray *numeratorValues = [[NSMutableArray alloc] initWithCapacity:126];
    for (int i = 1; i <= 126; i++) {
        [numeratorValues addObject:[NSNumber numberWithInt:i]];
    }
    return numeratorValues;
}

+ (NSArray *)timesignatureDenominatorValues
{
    NSMutableArray *denominatorValues = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 0; i < 6; i++) {
        [denominatorValues addObject:[NSNumber numberWithInt:pow(2, i)]];
    }
    return denominatorValues;
}


+ (double)doubleValueForTimeDenominator:(NSNumber *)denominator
{
    return 1.0/[denominator doubleValue];
}

+ (double)doubleValueForNoteValue:(NSString *)noteValue
{
    if ([noteValue isEqualToString:kWholeNote]) {
        return 1.0;
    }else if ([noteValue isEqualToString:kDottedHalfNote]){
        return .75;
    }else if ([noteValue isEqualToString:kHalfNote]){
        return .5;
    }else if ([noteValue isEqualToString:kDottedQuarterNote]){
        return .375;
    }else if ([noteValue isEqualToString:kQuarterNote]){
        return .25;
    }else if ([noteValue isEqualToString:kDottedEigthNote]){
        return .1875;
    }else if ([noteValue isEqualToString:kEigthNote]){
        return .125;
    }else if ([noteValue isEqualToString:kSixteenthNote]){
        return .0625;
    }
#ifdef DEBUG
    NSLog(@"Undefined notevalue: %s %d", __FUNCTION__, __LINE__);
#endif
    return 1.0;
}

+ (UIImage *)noteValueImageForTimeDenominator:(NSNumber *)denominator 
                               imageSpecifier:(NoteValueImageSpecifier)specifier
{

    NSString *imageName = nil;
    double value = [denominator doubleValue];
    if (equalsd(value, 1)) {
        imageName = @"whole_note";
    }else if (equalsd(value, [Helpers doubleValueForNoteValue:kDottedHalfNote])) {
        imageName = @"dotted_half_note";
    }else if (equalsd(value, 2)) {
        imageName = @"half_note";
    }else if (equalsd(value, [Helpers doubleValueForNoteValue:kDottedQuarterNote])) {
        imageName = @"dotted_quarter_note";
    }else if (equalsd(value, 4)) {
        imageName = @"quarter_note";
    }else if (equalsd(value, [Helpers doubleValueForNoteValue:kDottedEigthNote])) {
        imageName = @"dotted_eigth_note";
    }else if (equalsd(value, 8)) {
        imageName = @"eigth_note";
    }else if (equalsd(value, 16)) {
        imageName = @"sixteenth_note";
    }else if (equalsd(value, 32)) {
        imageName = @"thirtysecond_note";
    }

    
    UIImage * image = [UIImage imageNamed:imageName];
    if (NoteValueImageSpecifierPetrol == specifier) {
        image = [image imageWithOverlayColor:[Helpers petrol]];
    }else if (NoteValueImageSpecifierWhite == specifier) {
        image = [image imageWithOverlayColor:[UIColor whiteColor]];
    }
    return image;
}

+ (UIImage *)noteValueImageForNoteValueString:(NSString *)noteValue 
                               imageSpecifier:(NoteValueImageSpecifier)specifier
{
    NSNumber *denominator = [NSNumber numberWithInt:1];
    
    if ([noteValue isEqualToString:kWholeNote]) {
        denominator = [NSNumber numberWithInt:1];
    }else if ([noteValue isEqualToString:kDottedHalfNote]) {
        denominator = [NSNumber numberWithDouble:[Helpers doubleValueForNoteValue:kDottedHalfNote]];
    }else if ([noteValue isEqualToString:kHalfNote]) {
        denominator = [NSNumber numberWithInt:2];
    }else if ([noteValue isEqualToString:kDottedQuarterNote]) {
        denominator = [NSNumber numberWithDouble:[Helpers doubleValueForNoteValue:kDottedQuarterNote]];
    }else if ([noteValue isEqualToString:kQuarterNote]) {
        denominator = [NSNumber numberWithInt:4];
    }else if ([noteValue isEqualToString:kDottedEigthNote]) {
        denominator = [NSNumber numberWithDouble:[Helpers doubleValueForNoteValue:kDottedEigthNote]];
    }else if ([noteValue isEqualToString:kEigthNote]) {
        denominator = [NSNumber numberWithInt:8];
    }else if ([noteValue isEqualToString:kSixteenthNote]) {
        denominator = [NSNumber numberWithInt:16];
    }
    
    return [Helpers noteValueImageForTimeDenominator:denominator imageSpecifier:specifier];
}


#pragma mark - Translations
+ (NSString *)localizedPerformanceModeStringForMode:(PerformanceMode)theMode
{
    switch (theMode) {
        case PerformanceModeSimpleScroll:
            return MyLocalizedString(@"simplePerformanceMode", nil);
            break;
        case PerformanceModeAdvancedScroll:
            return MyLocalizedString(@"advancedPerformanceMode", nil);
            break;
        case PerformanceModePage:
            return  MyLocalizedString(@"pagingPerformanceMode", nil);
            break;
        default:
            return @"";
            break;
    }
}

+ (NSString *)eventTrackingStringForPerformanceMode:(PerformanceMode)theMode
{
    switch (theMode) {
        case PerformanceModeSimpleScroll:
            return @"Simple roll mode";
            break;
        case PerformanceModeAdvancedScroll:
            return @"Roll by measure mode";
            break;
        case PerformanceModePage:
            return  @"Manual mode";
            break;
        default:
            return @"";
            break;
    }
}

+ (NSString *)viewTrackingStringForPerformanceMode:(PerformanceMode)theMode
{
    switch (theMode) {
        case PerformanceModeSimpleScroll:
            return @"PerformanceSimpleRollViewController";
            break;
        case PerformanceModeAdvancedScroll:
            return @"PerformanceRollByMeasureViewController";
            break;
        case PerformanceModePage:
            return  @"PerformancePagingViewController";
            break;
        default:
            return @"";
            break;
    }
}

+ (NSString *)trackingStringForEditorType:(EditorViewControllerType)theType
{
    switch (theType) {
        case EditorViewControllerTypeMeasures:
            return @"MeasureEditor";
            break;
        case EditorViewControllerTypeAnnotations:
            return @"AnnotationEditor";
            break;
        case EditorViewControllerTypeStartMeasure:
            return  @"StartMeasureEditor";
            break;
        default:
            return @"";
            break;
    }
}

+ (NSString *)localizedEditorTypeStringForType:(EditorViewControllerType)theType
{
    switch (theType) {
        case EditorViewControllerTypeMeasures:
            return MyLocalizedString(@"editorTypeMeasures", nil);
            break;
        case EditorViewControllerTypeAnnotations:
            return MyLocalizedString(@"editorTypeAnnotations", nil);
            break;
        case EditorViewControllerTypeStartMeasure:
            return  MyLocalizedString(@"editorTypeStartMeasure", nil);
            break;
        default:
            return @"";
            break;
    }
}

+ (NSSet *)doneBarButtonPossibleTitles
{
    return [NSSet setWithObjects:@"Done", @"Fertig", @"Fait", @"Listo", nil];
}

+ (NSSet *)penBarButtonPossibleTitles
{
    return [NSSet setWithObjects:@"Pen", @"Stift", @"Stylo", @"Lápiz", nil];
}

+ (NSURL *)localizedTutorialMovieUrlForTutorialType:(TutorialType)theType
{
    switch (theType) {
        case TutorialTypeSimplePerformance:
            return [NSURL URLWithString:MyLocalizedString(@"simplePerformanceModeTutorialMovie", nil)];
            break;
        case TutorialTypeAdvancedPerformance:
            return [NSURL URLWithString:MyLocalizedString(@"advancedPerformanceModeTutorialMovie", nil)];
            break;
        case TutorialTypePagingPerformance:
            return [NSURL URLWithString:MyLocalizedString(@"pagingPerformanceModeTutorialMovie", nil)];
            break;
        case TutorialTypeAnnotationsEditor:
            return [NSURL URLWithString:MyLocalizedString(@"annotationsEditorTutorialMovie", nil)];
            break;
        case TutorialTypeMeasureEditor:
            return [NSURL URLWithString:MyLocalizedString(@"measureEditorTutorialMovie", nil)];
            break;
        case TutorialTypeStartMeasureEditor:
            return [NSURL URLWithString:MyLocalizedString(@"startMeasureEditorTutorialMovie", nil)];
            break;
        case TutorialTypeImport:
            return [NSURL URLWithString:MyLocalizedString(@"importTutorialMovie", nil)];
            break;
        default:
            return nil;
            break;
    }
}

+ (NSString *)localizedTutorialDescriptionForTutorialType:(TutorialType)theType
{
    switch (theType) {
        case TutorialTypeSimplePerformance:
            return MyLocalizedString(@"tutorialDescriptionSimpleMode", nil);
            break;
        case TutorialTypeAdvancedPerformance:
            return MyLocalizedString(@"tutorialDescriptionAdvancedMode", nil);
            break;
        case TutorialTypePagingPerformance:
            return MyLocalizedString(@"tutorialDescriptionPagingMode", nil);
            break;
        case TutorialTypeAnnotationsEditor:
            return MyLocalizedString(@"tutorialDescriptionAnnotationsEditor", nil);            
            break;
        case TutorialTypeMeasureEditor:
            return MyLocalizedString(@"tutorialDescriptionMeasureEditor", nil);
            break;
        case TutorialTypeStartMeasureEditor:
            return MyLocalizedString(@"tutorialDescriptionStartMeasureEditor", nil);
            break;
        case TutorialTypeImport:
            return MyLocalizedString(@"tutorialDescriptionImport", nil);
            break;
        default:
            return nil;
            break;
    }
}

+ (NSString *)localizedTutorialTitleForTutorialType:(TutorialType)theType
{
    switch (theType) {
        case TutorialTypeSimplePerformance:
            return MyLocalizedString(@"simplePerformanceMode", nil);
            break;
        case TutorialTypeAdvancedPerformance:
            return MyLocalizedString(@"advancedPerformanceMode", nil);
            break;
        case TutorialTypePagingPerformance:
            return MyLocalizedString(@"pagingPerformanceMode", nil);
            break;
        case TutorialTypeAnnotationsEditor:
            return MyLocalizedString(@"tutorialTitleAnnotationsEditor", nil);            
            break;
        case TutorialTypeMeasureEditor:
            return MyLocalizedString(@"tutorialTitleMeasureEditor", nil);
            break;
        case TutorialTypeStartMeasureEditor:
            return MyLocalizedString(@"tutorialTitleStartMeasureEditor", nil);
            break;
        case TutorialTypeImport:
            return MyLocalizedString(@"tutorialTitleImport", nil);
            break;
        default:
            return nil;
            break;
    }
}

+ (UIImage *)splashImageForTutorialType:(TutorialType)theType
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    switch (theType) {
        case TutorialTypeSimplePerformance:
            return [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"simpleTutorialSplash" 
                                                                         ofType:@"png"]];
            break;
        case TutorialTypeAdvancedPerformance:
            return [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"advancedTutorialSplash" 
                                                                         ofType:@"png"]];
            break;
        case TutorialTypePagingPerformance:
            return [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"pagingTutorialSplash" 
                                                                         ofType:@"png"]];
            break;
        case TutorialTypeAnnotationsEditor:
            return [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"annotationsEditorTutorialSplash" 
                                                                         ofType:@"png"]];            
            break;
        case TutorialTypeMeasureEditor:
            return [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"measureEditorTutorialSplash" 
                                                                         ofType:@"png"]];
            break;
        case TutorialTypeStartMeasureEditor:
            return [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"startMeasureTutorialSplash" 
                                                                         ofType:@"png"]];
            break;
        case TutorialTypeImport:
            return [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"importTutorialSplash" 
                                                                         ofType:@"png"]];
            break;
        default:
            return nil;
            break;
    }
}


+ (NSString *)localizedPerformanceScrollPositionName:(PerformanceScrollPosition)position
{
    switch (position) {
        case PerformanceScrollPositionAutomatic:
            return MyLocalizedString(@"settingsScrollPositionAutomatic", nil);
            break;
        case PerformanceScrollPositionTop:
            return MyLocalizedString(@"settingsScrollPositionTop", nil);
            break;
        case PerformanceScrollPositionMiddle:
            return MyLocalizedString(@"settingsScrollPositionMiddle", nil);
            break;
        case PerformanceScrollPositionBottom:
            return MyLocalizedString(@"settingsScrollPositionBottom", nil);
            break;
    }
#ifdef DEBUG
    NSLog(@"Invalid scroll position %s %d", __func__, __LINE__);
#endif
    return @"-----";
}

#pragma mark - Colors

+ (UIColor*)centralViewBrown
{
    return [UIColor colorWithRed:32.0/255 green:28.0/255 blue:25.0/255 alpha:1.0];
}

+ (UIColor *)babyBlue
{
    return [UIColor colorWithRed:226.0/255 green:229.0/255 blue:234.0/255 alpha:1.0];
}

+ (UIColor *)darkerBabyBlue
{
    return [UIColor colorWithRed:212.0/255.0 green:213.0/255.0 blue:218.0/255.0 alpha:1.0];
}
+ (UIColor *)labelBlue
{
    return [UIColor colorWithRed:76.0/255.0 green:84.0/255.0 blue:109.0/255.0 alpha:1.0];
}

+ (UIImage*)helperArrowDown
{
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hint_arrow" ofType:@"png"]];
}

+ (UIColor *)measureHighlightColor
{
    return [UIColor colorWithRed:54.0/255.0 green:207.0/255.0 blue:215.0/255.0 alpha:1.0];
}

#pragma mark - New Colors

+ (UIColor *)grey
{
    return [UIColor colorWithRed:180.0/255.0 green:188.0/255.0 blue:190.0/255.0 alpha:1.0];
}

+ (UIColor *)lightGrey
{
    return [UIColor colorWithRed:230.0/255.0 green:232.0/255.0 blue:231.0/255.0 alpha:1.0];
}

+ (UIColor *)black
{
    return [UIColor colorWithRed:12.0/255.0 green:36.0/255.0 blue:40.0/255.0 alpha:1.0];
}

+ (UIColor *)petrol
{
    return [UIColor colorWithRed:28.0/255.0 green:106.0/255.0 blue:118.0/255.0 alpha:1.0];
}

+ (UIColor *)lightPetrol
{
    return [UIColor colorWithRed:186.0/255.0 green:210.0/255.0 blue:214.0/255.0 alpha:1.0];
}

+ (UIColor *)lightBlue
{
    return [UIColor colorWithRed:64.0/255.0 green:76.0/255.0 blue:78.0/255.0 alpha:1.0];
}

+ (UIColor *)darkYellow
{
    return [UIColor colorWithRed:205.0/255.0 green:211.0/255.0 blue:167.0/255.0 alpha:1.0];
}

+ (UIColor *)yellow
{
    return [UIColor colorWithRed:249.0/255.0 green:255.0/255.0 blue:145.0/255.0 alpha:1.0];
}

+ (UIColor *)lightYellow
{
    return [UIColor colorWithRed:252.0/255.0 green:255.0/255.0 blue:186.0/255.0 alpha:1.0];
}

+ (UIColor *)red
{
    return [UIColor colorWithRed:233.0f/255.0f green:66.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
}

#pragma mark - Fonts

+ (UIFont*)avenirNextRegularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

+ (UIFont*)avenirNextMediumFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont*)avenirNextCondensedDemiBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:size];
}

#pragma mark - Number comparison

int equalsd (double a, double b) {
    return (fabs(a - b) < DBL_EPSILON);
}

int equalsf (float a, float b) {
    return (fabsf(a - b) < FLT_EPSILON);
}

#pragma mark - SignAnnotations

+ (NSArray*)signAnnotationCategoryKeys
{
    NSArray *categoryKeys = @[
            @"annotationCategoryArticulations",
            @"annotationCategoryFingerings",
            @"annotationCategoryDynamics",
            @"annotationCategoryOrnaments"
    ];
    
    return categoryKeys;
}

+ (NSString*)signAnnotationCategoryNameForKey:(NSString*)categoryKey
{
    NSString *categoryName = nil;
    SignAnnotationCategoryType categoryType;
    NSArray *categoryKeys = [Helpers signAnnotationCategoryKeys];
    
    if ([categoryKeys containsObject:categoryKey]) {
        categoryType = [categoryKeys indexOfObject:categoryKey];
    } else {
        return nil;
    }

    
    switch (categoryType) {
        case SignAnnotationCategoryFingerings:
            categoryName = MyLocalizedString(@"annotationCategoryFingerings", nil);
            break;
            
        case SignAnnotationCategoryArticulations:
            categoryName = MyLocalizedString(@"annotationCategoryArticulations", nil);
            break;
            
        case SignAnnotationCategoryDynamics:
            categoryName = MyLocalizedString(@"annotationCategoryDynamics", nil);
            break;
        case SignAnnotationCategoryOrnaments:
            categoryName = MyLocalizedString(@"annotationCategoryOrnaments", nil);
            break;
        
        default:
            break;
    }
    
    return categoryName;
}

+ (NSArray*)signAnnotationKeysForCategory:(NSString*)categoryKey
{
    NSArray *signAnnotations = nil;
    SignAnnotationCategoryType categoryType;
    NSArray *categoryKeys = [Helpers signAnnotationCategoryKeys];
    
    if ([categoryKeys containsObject:categoryKey]) {
        categoryType = [categoryKeys indexOfObject:categoryKey];
    } else {
        return nil;
    }
    
    switch (categoryType) {
        case SignAnnotationCategoryFingerings:
            signAnnotations = @[
                    @"fingering_zero",
                    @"fingering_one",
                    @"fingering_two",
                    @"fingering_three",
                    @"fingering_four",
                    @"fingering_five",
                    @"fingering_p",
                    @"fingering_i",
                    @"fingering_m",
                    @"fingering_a",
                    @"string_zero",
                    @"string_one",
                    @"string_two",
                    @"string_three",
                    @"string_four",
                    @"string_five",
                    @"string_six",
                    @"string_seven",
                    @"string_eight",
                    @"string_nine"
            ];
            break;
            
        case SignAnnotationCategoryArticulations:
            signAnnotations = @[
                    @"down_stroke",
                    @"up_stroke",
                    @"slur",
                    @"slur_down",
                    @"slur_up",
                    @"staccato",
                    @"staccatissimo",
                    @"breath_mark",
                    @"wedge",
                    @"accent",
                    @"tenuto",
                    @"natural_harmonic",
                    @"pizzicato",
                    @"snap_pizzicato",
                    @"fermata",
                    @"marcato",
                    @"pedaldown",
                    @"pedalup"
            ];
            break;
            
        case SignAnnotationCategoryDynamics:
            signAnnotations = @[
                    @"crescendo",
                    @"diminuendo",
                    @"pianississimo",
                    @"pianissimo",
                    @"mezzo_piano",
                    @"piano",
                    @"mezzo_forte",
                    @"forte",
                    @"fortissimo",
                    @"fortississimo",
                    @"forte_piano",
                    @"sforzando"
            ];
            break;
            
        case SignAnnotationCategoryOrnaments:
            signAnnotations = @[
                    @"trill",
                    @"mordent",
                    @"lower_mordent",
                    @"turn",
                    @"turn_inverted"
            ];
            break;
            
        default:
            break;
    }
    
    return signAnnotations;
}

+ (NSString*)signAnnotationCategoryForSignAnnotation:(NSString*)signAnnotationKey
{
    NSArray *categoryKeys = [self signAnnotationCategoryKeys];
    
    for (NSString *categoryKey in categoryKeys) {
        NSArray *signAnnotationKeys = [self signAnnotationKeysForCategory:categoryKey];
        NSInteger index = [signAnnotationKeys indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [(NSString *)obj isEqualToString:signAnnotationKey];
        }];
        
        if (index != NSNotFound) {
            return categoryKey;
        }
    }
    
    return nil;
}

#pragma mark - SignAnnotation Colors

+ (NSArray*)annotationColors
{
    NSArray *colors = @[
            [UIColor blackColor],
            [UIColor whiteColor],
            [UIColor yellowColor],
            [UIColor redColor],
            [UIColor blueColor],
            [UIColor greenColor],
            [UIColor purpleColor]
    ];
    return colors;
}

+ (NSArray*)annotationColorNames
{
    NSArray *colorNames = @[
            MyLocalizedString(@"blackColorName", nil),
            MyLocalizedString(@"whiteColorName", nil),
            MyLocalizedString(@"markerColorName", nil),
            MyLocalizedString(@"redColorName", nil),
            MyLocalizedString(@"blueColorName", nil),
            MyLocalizedString(@"greenColorName", nil),
            MyLocalizedString(@"purpleColorName", nil)
    ];
    return colorNames;
}

#pragma mark - Buttons

+ (UIBarButtonItem*)doneBarButtonItemWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithTitle:MyLocalizedString(@"buttonDone", nil) style:UIBarButtonItemStylePlain target:target action:action];
}

+ (UIBarButtonItem*)shareBarButtonItemWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"export"] style:UIBarButtonItemStylePlain target:target action:action];
}

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - UIAlertController

+ (UIAlertController*)maxScoresReachedAlerController
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"maxScoresReachedAlertViewTitle", nil)
                                                                   message:[NSString stringWithFormat:MyLocalizedString(@"maxScoresReachedAlertViewMessageImport", nil), NumberOfSampleScores]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    
    return alert;
}

+ (UIAlertController*)alertControllerWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    return alert;
}


#pragma mark - File Operations

+ (BOOL)verifyPdfFile:(NSString *)pdfFilePath
{
    // convert path to url
    NSURL *pdfUrl = [NSURL fileURLWithPath:pdfFilePath];
    if (APP_DEBUG) {
        NSLog(@"%s: file url to verify: %@", __func__, pdfUrl);
    }

    // check if the file is a valid pdf file
    CGPDFDocumentRef testDocument = CGPDFDocumentCreateWithURL ((__bridge CFURLRef) pdfUrl);
    if (NULL == testDocument) {
        if (APP_DEBUG) {
            NSLog(@"%s: verify negative", __func__);
        }

        CGPDFDocumentRelease (testDocument);
        return FALSE;
    } else {
        if (APP_DEBUG) {
            NSLog(@"%s: verify positive", __func__);
        }

        CGPDFDocumentRelease (testDocument);
        return TRUE;
    }
}

+ (BOOL)removeFileAtPath:(NSString*)filePath
{
    if (nil == filePath) {
        return FALSE;
    } else {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        
        if (nil == error) {
            return TRUE;
        } else {
            if (APP_DEBUG) {
                NSLog(@"%s: Error while deleting file: %@: %@", __func__, error, [error localizedDescription]);
            }
            return FALSE;
        }
    }
}



@end
