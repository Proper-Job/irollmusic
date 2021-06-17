//
//  ScoreRotationOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import <Foundation/Foundation.h>

@class Score;

@interface ScoreRotationOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic, strong) NSManagedObjectID *scoreId;
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithObjectID:(NSManagedObjectID*)scoreId;

- (void)setCompletionBlockWithSuccess:(void (^)(NSManagedObjectID *scoreId))success
                              failure:(void (^)(NSManagedObjectID *scoreId))failure;
- (void)setProgressBlock:(void (^)(NSString *scoreName, CGFloat progress))block;

@end
