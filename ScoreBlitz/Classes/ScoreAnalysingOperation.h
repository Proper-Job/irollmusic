//
//  ScoreAnalysingOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.01.15.
//
//

#import <Foundation/Foundation.h>

@class Score;

@interface ScoreAnalysingOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic, strong) NSManagedObjectID *scoreId;
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign) NSInteger numberOfPages;

- (id)initWithObjectID:(NSManagedObjectID*)scoreId;
- (void)setCompletionBlockWithSuccess:(void (^)(NSManagedObjectID *scoreId))success
                              failure:(void (^)(NSManagedObjectID *scoreId))failure;
- (void)setProgressBlock:(void (^)(NSString *scoreName, CGFloat progress))block;

@end
