//
// Created by Moritz Pfeiffer on 31/07/15.
//

#import <Foundation/Foundation.h>


@interface MetricsManager : NSObject

+ (CGFloat)scorePreviewReductionFactor;
+ (CGFloat)scoreMagnificationScale;
+ (CGFloat)scoreWidthAtFullScale;
+ (CGFloat)scrollingPagePadding;
+ (CGFloat)simpleScrollStep;
+ (CGFloat)longestScreenSide;
+ (CGFloat)shortestScreenSide;



+ (CGFloat)scorePreviewImageLongestSide;
+ (CGFloat)scorePreviewImageShortestSide;
//+ (CGFloat)pageHeightPortrait;
//+ (CGFloat)pageHeightLandscape;
//+ (CGFloat)pageWidthPortrait;
//+ (CGFloat)pageWidthLandscape;

@end