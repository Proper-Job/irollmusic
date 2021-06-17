//
//  QueryHelper.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import "QueryHelper.h"
#import "ScoreBlitzAppDelegate.h"
#import "Purchase.h"

@implementation QueryHelper

+ (NSMutableArray *)allScores
{
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Score"];
    
    NSMutableArray *allScores = [NSMutableArray arrayWithArray:[UIAppDelegate.managedObjectContext executeFetchRequest:request error:&error]];
    
    if (nil != error) {
#ifdef DEBUG
        NSLog(@"%s: %@: %@", __func__, error, [error localizedDescription]);
#endif
        return nil;
    } else {
        return allScores;
    }
}

+ (BOOL)canImportFiles:(NSInteger)fileNumber
{
    return YES;
}

@end
