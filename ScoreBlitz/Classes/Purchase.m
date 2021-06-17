//
//  Purchase.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 03.08.15.
//
//

#import "Purchase.h"
#import "ScoreBlitzAppDelegate.h"

@implementation Purchase

@dynamic productId;
@dynamic validUntil;

+ (Purchase*)validPurchase
{
    NSFetchRequest *fetchrequest = [NSFetchRequest fetchRequestWithEntityName:@"Purchase"];
    fetchrequest.predicate = [NSPredicate predicateWithFormat:@"validUntil >= %@", [NSDate date]];
    
    NSError *error = nil;
    NSArray *result = [[UIAppDelegate managedObjectContext] executeFetchRequest:fetchrequest error:&error];
    
#ifdef DEBUG
    if (error != nil) {
        NSLog(@"%s: error: %@", __func__, [error localizedDescription]);
    }
#endif
    
    if ([result count] == 1) {
        return [result firstObject];
    } else {
        if ([result count] > 1) {
#ifdef DEBUG
            if (error != nil) {
                NSLog(@"%s: more than one purchase found, this is a problem", __func__);
            }
#endif
        }
        return nil;
    }
}

@end
