//
//  Repeat.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 26.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Measure;

@interface Repeat : NSManagedObject {

}
@property (nonatomic, strong) NSNumber * numberOfRepeats;
@property (nonatomic, strong) Measure * endMeasure;
@property (nonatomic, strong) Measure * startMeasure;

+ (NSEntityDescription *)entityDescription;

@end
