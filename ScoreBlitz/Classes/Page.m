 //
//  Page.m
//  ScorePad
//
//  Created by Moritz Pfeiffer on 13.12.10.
//  Copyright 2010 Alp Phone. All rights reserved.
//

#import "Page.h"
#import "ScoreBlitzAppDelegate.h"
#import "Score.h"
#import "DrawAnnotation.h"
#import "TextAnnotation.h"
#import "SignAnnotation.h"
#import "NSNumberExtensions.h"
#import "MetricsManager.h"

 @implementation Page

@dynamic number, score, contentBoxAsString, positionOnCanvasPortrait, positionOnCanvasLandscape,
heightPortrait, heightLandscape, measures;
@dynamic drawAnnotationsData;
@dynamic textAnnotationsData;
@dynamic widthLandscape;
@dynamic widthPortrait;
@dynamic signAnnotationsData;


+ (NSEntityDescription *)entityDescription
{
	NSManagedObjectContext *context = [(ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return [NSEntityDescription entityForName:@"Page" inManagedObjectContext:context];
}

- (CGRect)contentBox
{
	return CGRectFromString(self.contentBoxAsString);
}

- (void)setContentBox:(CGRect)contentBox
{
	self.contentBoxAsString = NSStringFromCGRect(contentBox);
}

- (void)flipContentBox
{
    CGRect contentBox = [self contentBox];
    contentBox = CGRectMake(contentBox.origin.x,
                            contentBox.origin.y,
                            contentBox.size.height,
                            contentBox.size.width);
    [self setContentBox:contentBox];
}

- (BOOL)isPortrait
{
	if ([self contentBox].size.height > [self contentBox].size.width) {
		return YES;
	}else {
		return NO;
	}
}
- (UIImage *)previewImage
{
    NSString *path = [[self.score scoreDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:kPreviewImageLargeFormatString, [self.number intValue]]];
    return [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:path]];
}

- (UIImage *)previewImageSmall
{
    NSString *path = [[self.score scoreDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:kPreviewImageSmallFormatString, [self.number intValue]]];
    return [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:path]];
}

- (NSArray *)measuresSortedByCoordinates
{
    if (nil != self.measures) {
        NSSortDescriptor *xCoordinateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"xCoordinate" ascending:YES];
        NSSortDescriptor *yCoordinateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"yCoordinate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:yCoordinateDescriptor, xCoordinateDescriptor, nil];
        return [self.measures sortedArrayUsingDescriptors:sortDescriptors];
    }else {
        return [NSMutableArray array];
    }
}

- (void)saveDrawAnnotations:(NSMutableArray *)drawAnnotations
{
    self.drawAnnotationsData = [NSKeyedArchiver archivedDataWithRootObject:drawAnnotations];
}

- (void)saveTextAnnotations:(NSMutableArray *)textAnnotations
{
    self.textAnnotationsData = [NSKeyedArchiver archivedDataWithRootObject:textAnnotations];
}

- (void)saveSignAnnotations:(NSMutableArray*)signAnnotations
{
    self.signAnnotationsData = [NSKeyedArchiver archivedDataWithRootObject:signAnnotations];
}

- (NSMutableArray *)restoreDrawAnnotations
{
    if (nil != self.drawAnnotationsData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.drawAnnotationsData];
    } else {
        return nil;
    }
}

- (NSMutableArray *)restoreTextAnnotations
{
    if (nil != self.textAnnotationsData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.textAnnotationsData];
    } else {
        return nil;
    }
}

- (NSMutableArray*)restoreSignAnnotations
{
    if (nil != self.signAnnotationsData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.signAnnotationsData];
    } else {
        return nil;
    }
}

- (NSDictionary *)annotationsDictionaryForFrameSize:(CGSize)size invertY:(BOOL)invertY
{
    NSMutableArray *drawAnnotations = [self restoreDrawAnnotations];
    NSMutableArray *textAnnotations = [self restoreTextAnnotations];
    
    NSMutableArray *strings = [NSMutableArray array];    
    NSMutableArray *pointsForStrings = [NSMutableArray array];
    NSMutableArray *fontNameForStrings = [NSMutableArray array];
    NSMutableArray *fontSizeForStrings = [NSMutableArray array];
    
    NSMutableArray *bezierPaths = [NSMutableArray array];
    NSMutableArray *colorsForBezierPaths = [NSMutableArray array];
    NSMutableArray *alphaForBezierPaths = [NSMutableArray array];
    
    for (DrawAnnotation *drawAnnotation in drawAnnotations) {
        UIBezierPath *bezierPathCache;
        for (NSValue *pointValue in drawAnnotation.relativePointsOfBezierPath) {
            CGPoint point = [pointValue CGPointValue];
            point.x = roundf(point.x * size.width);
            if (invertY) {
                point.y = roundf(size.height - (point.y * size.height));
            } else {
                point.y = roundf(point.y * size.height);
            }
#ifdef DEBUG
            if (point.y < 0) {
                NSLog(@"Page: annotationsDictionaryForFrameSize bezierPathPoint: x%f y%f", point.x, point.y);
            }
#endif
            
            // create BezierPath with absolute point
            if ([drawAnnotation.relativePointsOfBezierPath indexOfObject:pointValue] == 0) {
                bezierPathCache = [UIBezierPath bezierPath];
                bezierPathCache.lineWidth = [drawAnnotation relativeLineWidthForSize:size];
                [bezierPathCache moveToPoint:point];
                [bezierPaths addObject:bezierPathCache];
                [colorsForBezierPaths addObject:drawAnnotation.color];
                [alphaForBezierPaths addObject:drawAnnotation.alpha];
            } else {
                [bezierPathCache addLineToPoint:point];
            }
        }
    }
    
    for (TextAnnotation *textAnnotation in textAnnotations) {
        CGPoint point = [textAnnotation.relativeOriginOfTextField CGPointValue];
        point.x = roundf(point.x * size.width);
        if (invertY) {
            point.y = roundf(size.height - (point.y * size.height));
        } else {
            point.y = roundf(point.y * size.height);
        }
#ifdef DEBUG
        if (point.y < 0) {
            NSLog(@"Page: annotationsDictionaryForFrameSize textFieldPoint: x%f y%f", point.x, point.y);
        }
#endif
        [strings addObject:textAnnotation.text];
        [pointsForStrings addObject:[NSValue valueWithCGPoint:point]];
        [fontNameForStrings addObject:textAnnotation.textFontName];
        [fontSizeForStrings addObject:[textAnnotation relativeFontSizeForSize:size]];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:strings,kAnnotationStrings, pointsForStrings, kAnnotationStringPoints, fontNameForStrings, kAnnotationFontName, fontSizeForStrings, kAnnotationFontSize, bezierPaths, kAnnotationBezierPaths, colorsForBezierPaths, kAnnotationBezierPathColors, alphaForBezierPaths, kAnnotationBezierPathAlpha, nil];
    
}

// these signAnnotations need to be retained while showing their caLayers
// you need to remove the layers manualy from hosting view before dismissing the hosting view, otherwise the caLayer 
// gets overreleased and causes a crash
- (NSArray*)signAnnotationsForFrameSize:(CGSize)newSize 
{
    NSMutableArray *signAnnotations = [self restoreSignAnnotations];
    
    NSDictionary *argumentsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:CGRectMake(0, 0, newSize.width, newSize.height)], kSignAnnotationSetupArgumentFrame, nil, kSignAnnotationSetupArgumentDelegate, [NSNumber numberWithBool:NO], kSignAnnotationSetupArgumentInvertY, nil];
    [signAnnotations makeObjectsPerformSelector:@selector(setupWithArgumentsDictionary:) withObject:argumentsDictionary];
    
    return signAnnotations;
}


- (CGFloat)positionOnCanvas
{
    return [self.positionOnCanvasPortrait floatValue];
}

- (CGFloat)height
{
    // This is actually identical to the value in self.heightPortrait and self.heightLandscape.
    // But let's move away from that crazy approach and make page display more dynamic.
    CGFloat scaleFactor = [MetricsManager scoreWidthAtFullScale] / [self contentBox].size.width;
    return roundf([self contentBox].size.height * scaleFactor);
}

- (CGFloat)width
{
    // This is actually identical to the value in self.widthPortrait and self.widthLandscape.
    // But let's move away from that crazy approach and make page display more dynamic.
    return [MetricsManager scoreWidthAtFullScale];
}

@end
