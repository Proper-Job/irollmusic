//
//  DrawAnnotation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawAnnotation : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSNumber *alpha, *lineWidth;
@property (nonatomic, strong) NSValue *originalFrame;
@property (nonatomic, strong) NSMutableArray *relativePointsOfBezierPath;

- (NSArray *)pointsOfBezierPath;
- (void)createRelativePointsOfBezierPath;
- (void)adjustLineWithOfBezierPathWithSize:(CGSize)newSize;
- (CGFloat)relativeLineWidthForSize:(CGSize)newSize;

@end
