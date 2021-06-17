//
//  ScoreDetailItem.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    ScoreDetailTableViewCellTypeName,
    ScoreDetailTableViewCellTypeComposer,
    ScoreDetailTableViewCellTypeGenre,
    ScoreDetailTableViewCellTypePlaytime,
    ScoreDetailTableViewCellTypeAutomaticCalculation,
    ScoreDetailTableViewCellTypePreview
}ScoreDetailTableViewCellType;

@interface ScoreDetailRowItem : NSObject

@property (nonatomic, assign) ScoreDetailTableViewCellType scoreDetailTableViewCellType;

@end
