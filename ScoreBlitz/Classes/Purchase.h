//
//  Purchase.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 03.08.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Purchase : NSManagedObject

@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSDate * validUntil;

+ (Purchase*)validPurchase;

@end
