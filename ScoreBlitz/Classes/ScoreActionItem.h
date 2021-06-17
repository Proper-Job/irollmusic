//
//  ScoreActionItem.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 24.03.15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    ScoreActionTypeAnalyseAllScores,
    ScoreActionTypeDeleteAllScores,
    ScoreActionTypeCheckDocumentsDirectory,
    ScoreActionTypeLinkDropbox,
    ScoreActionTypeUnlinkDropbox
} ScoreActionType;

@interface ScoreActionItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) ScoreActionType scoreActionType;

@end
