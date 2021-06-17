//
//  Score.h
//  ScorePad
//
//  Created by Moritz Pfeiffer on 13.12.10.
//  Copyright 2010 Alp Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Set;

@interface Score : NSManagedObject {
	CGPDFDocumentRef pdfDocument;
	NSArray *orderedPagesAsc, *orderedPagesDesc;
}

@property (nonatomic, strong) NSArray *orderedPagesAsc, *orderedPagesDesc;

@property (nonatomic, strong) NSString * artist;
@property (nonatomic, strong) NSNumber * canvasHeightLandscape;
@property (nonatomic, strong) NSNumber * canvasHeightPortrait;
@property (nonatomic, strong) NSString * composer;
@property (nonatomic, strong) NSString * genre;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * pdfFileName;
@property (nonatomic, strong) NSString * sha1Hash;
@property (nonatomic, strong) NSNumber * preferredPerformanceMode;
@property (nonatomic, strong) NSNumber * playTime;
@property (nonatomic, strong) NSNumber * isAnalyzed;
@property (nonatomic, strong) NSNumber * metronomeBpm;
@property (nonatomic, strong) NSString * metronomeNoteValue;
@property (nonatomic, strong) NSNumber * scrollSpeed;
@property (nonatomic, strong) NSNumber * automaticPlayTimeCalculation;
@property (nonatomic, strong) NSNumber * rotationAngle;

@property (nonatomic, strong) NSSet* pages;
@property (nonatomic, strong) NSSet* setListEntries;

+ (NSEntityDescription *)entityDescription;

- (NSString*)pdfFilePath;
- (NSURL *)scoreUrl;
- (NSString*)scoreDirectory;
- (NSString *)playTimeString;
- (void)refreshPlaytime;
- (NSArray *)measuresSortedByCoordinates;
- (CGFloat)canvasHeight;
@end

// coalesce these into one @interface Score (CoreDataGeneratedAccessors) section
@interface Score (CoreDataGeneratedAccessors)
- (void)addPagesObject:(NSManagedObject *)value;
- (void)removePagesObject:(NSManagedObject *)value;
- (void)addPages:(NSSet *)value;
- (void)removePages:(NSSet *)value;

- (void)addSetListEntriesObject:(NSManagedObject *)value;
- (void)removeSetListEntriesObject:(NSManagedObject *)value;
- (void)addSetListEntries:(NSSet *)value;
- (void)removeSetListEntries:(NSSet *)value;
@end
