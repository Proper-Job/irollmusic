//
//  ScoreDetailSectionItem.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    ScoreDetailTableViewSectionTypeHeader,
    ScoreDetailTableViewSectionTypeSpacer
}ScoreDetailTableViewSectionType;

@interface ScoreDetailSectionItem : NSObject

@property (nonatomic, strong) NSArray *rows;

@property (nonatomic, assign) ScoreDetailTableViewSectionType scoreDetailTableViewSectionType;

@end
