//
//  AnnotationPen.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 27.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnnotationPen : NSObject <NSCoding> {
    
}

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSNumber *lineWidth;
@property (nonatomic, strong) NSNumber *alpha;

@end
