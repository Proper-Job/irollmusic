//
//  QueryHelper.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import <Foundation/Foundation.h>

@interface QueryHelper : NSObject

+ (NSMutableArray *)allScores;
+ (BOOL)canImportFiles:(NSInteger)fileNumber;

@end
