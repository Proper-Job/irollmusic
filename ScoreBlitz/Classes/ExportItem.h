//
//  ExportItem.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    ExportTableViewCellStyleRegular,
    ExportTableViewCellStyleButton
} ExportTableViewCellStyle;

typedef enum {
    ExportActionTypeFileAnnotationsChecked,
    ExportActionTypePdfFile,
    ExportActionTypeIrmFile,
    ExportActionTypePrintAnnotationsChecked,
    ExportActionTypePrintModeChecked,
    ExportActionTypePrint
} ExportActionType;

@interface ExportItem : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) BOOL boolValue;
@property (nonatomic, assign) ExportTableViewCellStyle exportTableViewCellStyle;
@property (nonatomic, assign) ExportActionType exportActionType;

@end
