//
//  ImageTilingView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 06.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageTilingView.h"
#import "PerformanceAnnotationView.h"
#import "Page.h"
#import "Score.h"

@implementation ImageTilingView

+ (Class)layerClass {
	return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
		// levelsOfDetail and levelsOfDetailBias determine how
		// the layer is rendered at different zoom levels.
        tiledLayer.levelsOfDetail = 1;
        tiledLayer.levelsOfDetailBias = 0;
        
        self.annotationView = [[PerformanceAnnotationView alloc] initWithFrame:CGRectZero];
        self.annotationView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.annotationView];
        [self bringSubviewToFront:self.annotationView];
    }
    return self;
}

- (void)invalidate {
    self.layer.contents = nil;
}

- (void)willDisplay
{
    [self.layer setNeedsDisplay];
    [self.annotationView setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGSize tileSize = kScoreImageTileSize;
    
    int firstCol =(int)  floorf(CGRectGetMinX(rect) / tileSize.width);
    int lastCol = (int) floorf((CGRectGetMaxX(rect)-1) / tileSize.width);
    int firstRow = (int) floorf(CGRectGetMinY(rect) / tileSize.height);
    int lastRow = (int) floorf((CGRectGetMaxY(rect)-1) / tileSize.height);
    //NSLog(@"firstCol: %d, lastCol: %d, firstRow: %d lastRow: %d", firstCol, lastCol, firstRow, lastRow);
    for (NSInteger row = firstRow; row <= lastRow; row++) {
        for (NSInteger col = firstCol; col <= lastCol; col++) {
            UIImage *tile = [self tileAtCol:col row:row];
            
            CGRect tileRect = CGRectMake(tileSize.width * col, tileSize.height * row,
                                         tileSize.width, tileSize.height);
            
            tileRect = CGRectIntersection(self.bounds, tileRect);
            [tile drawInRect:tileRect];
        }
    }
}

- (UIImage *)tileAtCol:(NSInteger)col row:(NSInteger)row
{
    NSString *path = [[self.page.score scoreDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:kScoreImageTileFormatString, [self.page.number intValue], col, row]];
    //NSLog(@"path: %@", [path lastPathComponent]);
    return [UIImage imageWithContentsOfFile:path];  
}


@end
