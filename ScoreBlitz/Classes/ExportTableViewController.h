//
//  ExportTableViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 05.09.14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Score, APCheckedLabel;

@interface ExportTableViewController : UITableViewController <UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) Score *score;

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UIPrintInteractionController *printInteractionController;
@property (nonatomic, strong) NSString *exportFilePath;
@property (nonatomic, strong) APCheckedLabel *fileAnnotationsChecked, *printAnnotationsChecked, *printModeChecked;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (id)initWithScore:(Score*)score;

#define kScoreBlitzMimeType @"zip"
#define kPdfMimeType @"pdf"

@end
