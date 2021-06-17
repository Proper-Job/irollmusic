//
//  FileImportOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 26.03.15.
//
//

#import <Foundation/Foundation.h>

@interface FileImportOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}
@property (nonatomic, strong) NSString *filePath, *errorMessage;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign) BOOL failure;

- (id)initWithFilePath:(NSString*)filePath;
- (void)setCompletionBlockWithSuccess:(void (^)(NSString *filePath))success
                              failure:(void (^)(NSString *errorMessage))failure;

- (void)finishOperation;

@end
