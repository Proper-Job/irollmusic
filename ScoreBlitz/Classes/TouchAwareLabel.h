//
// Created by Moritz Pfeiffer on 24/03/15.
//

#import <Foundation/Foundation.h>


@interface TouchAwareLabel : UILabel

@property (nonatomic, copy) void (^touchesBegan)(TouchAwareLabel *label);

@end