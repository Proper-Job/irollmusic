//
// Created by Moritz Pfeiffer on 31/07/15.
//

#import "MetricsManager.h"


@implementation MetricsManager

+ (CGFloat)scorePreviewReductionFactor
{
    return 2.0f / 3.0f;
}

+ (CGFloat)scoreMagnificationScale
{
    return 1.25f;
}

+ (CGFloat)scoreWidthAtFullScale
{
    return [self longestScreenSide] * [self scoreMagnificationScale];
}

+ (CGFloat)scrollingPagePadding
{
    // This is already hard coded into the database for analyzed scores
    return 3.0f;
}

+ (CGFloat)simpleScrollStep
{
    return 160.0f;
}

+ (CGFloat)longestScreenSide
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    return MAX(bounds.size.width, bounds.size.height);
}

+ (CGFloat)shortestScreenSide
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    return MIN(bounds.size.width, bounds.size.height);
}

+ (CGFloat)scorePreviewImageLongestSide
{
    return roundf([self longestScreenSide] * (2.0f/3.0f));
}

+ (CGFloat)scorePreviewImageShortestSide
{
    return roundf([self shortestScreenSide] * (2.0f/3.0f));
}

//+ (CGFloat)pageHeightPortrait
//{
//
//}
//
//+ (CGFloat)pageHeightLandscape;
//+ (CGFloat)pageWidthPortrait;
//+ (CGFloat)pageWidthLandscape

@end