//
//  Page.h
//  ScorePad
//
//  Created by Moritz Pfeiffer on 13.12.10.
//  Copyright 2010 Alp Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Score, Measure;

@interface Page : NSManagedObject {

}

// Core Data Properties
@property (nonatomic, strong) NSString * contentBoxAsString;
@property (nonatomic, strong) NSNumber * number;
@property (nonatomic, strong) Score * score;
@property (nonatomic, strong) NSNumber * positionOnCanvasPortrait;
@property (nonatomic, strong) NSNumber * positionOnCanvasLandscape;
@property (nonatomic, strong) NSNumber * heightLandscape;
@property (nonatomic, strong) NSNumber * heightPortrait;
@property (nonatomic, strong) NSSet* measures;
@property (nonatomic, strong) NSData * drawAnnotationsData;
@property (nonatomic, strong) NSData * textAnnotationsData;
@property (nonatomic, strong) NSNumber * widthLandscape;
@property (nonatomic, strong) NSNumber * widthPortrait;
@property (nonatomic, strong) NSData * signAnnotationsData;  // data version 3

+ (NSEntityDescription *)entityDescription;

- (CGRect)contentBox;
- (void)setContentBox:(CGRect)contentBox;
- (void)flipContentBox;
- (BOOL)isPortrait;
- (NSArray *)measuresSortedByCoordinates;
- (UIImage *)previewImage;
- (UIImage *)previewImageSmall;

- (void)saveDrawAnnotations:(NSMutableArray *)drawAnnotations;
- (void)saveTextAnnotations:(NSMutableArray *)textAnnotations;
- (void)saveSignAnnotations:(NSMutableArray*)signAnnotations;
- (NSMutableArray *)restoreDrawAnnotations;
- (NSMutableArray *)restoreTextAnnotations;
- (NSMutableArray*)restoreSignAnnotations;

- (NSDictionary *)annotationsDictionaryForFrameSize:(CGSize)size invertY:(BOOL)invertY;
- (NSArray*)signAnnotationsForFrameSize:(CGSize)newSize;

// Width, height and position on canvas are identical for portrait and landscape
// Make a method that straightens this out without the need to migrate the database
- (CGFloat)positionOnCanvas;
- (CGFloat)height;
- (CGFloat)width;

@end

@interface Page (CoreDataGeneratedAccessors)
- (void)addMeasuresObject:(Measure *)value;
- (void)removeMeasuresObject:(Measure *)value;
- (void)addMeasures:(NSSet *)value;
- (void)removeMeasures:(NSSet *)value;
@end
