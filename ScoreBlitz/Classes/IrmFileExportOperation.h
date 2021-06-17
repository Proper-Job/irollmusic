//
//  IrmFileExportOperation.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 25.03.15.
//
//

#import "FileExportOperation.h"

@interface IrmFileExportOperation : FileExportOperation

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
