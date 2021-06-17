//
// Created by Moritz Pfeiffer on 24/03/15.
//

#import <Foundation/Foundation.h>

@class TouchAwareLabel;
@class Score;
@class EditorViewController;


@interface MultipleBpmEditorViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIPickerView *bpmPicker;
@property (nonatomic, strong) IBOutlet TouchAwareLabel *multiSelectionBpmLabel;
@property (nonatomic, strong) NSSet *measures;
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) NSArray *bpmValues;
@property (nonatomic, copy) void (^bpmDidChange)(NSNumber *bpm);

- (instancetype)initWithMeasures:(NSSet *)theMeasures
                           score:(Score *)theScore;

@end