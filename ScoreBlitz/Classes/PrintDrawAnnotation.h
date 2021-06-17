//
//  PrintDrawAnnotation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPTLayer.h"

@interface PrintDrawAnnotation : CPTLayer

@property (nonatomic, strong) NSArray *paths, *colors, *alphas;
@property (nonatomic, assign) CGRect rect;

@end
