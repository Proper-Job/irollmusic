//
//  Jump.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 28.04.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Measure;

@interface Jump : NSManagedObject {

}
@property (nonatomic, strong) NSNumber * jumpType;
@property (nonatomic, strong) NSNumber * takeRepeats;
@property (nonatomic, strong) Measure * originMeasure;
@property (nonatomic, strong) Measure * destinationMeasure;

+ (NSEntityDescription *)entityDescription;

@end
