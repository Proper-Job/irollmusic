//
//  EditorTypeChooserTableViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 16.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditorTypeChooserTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *modes;
@property (nonatomic, assign) EditorViewControllerType editorType;
@property (nonatomic, copy) void (^typePickedCompletion)(EditorViewControllerType newType);

- (id)initWithEditorType:(EditorViewControllerType)theType
    typePickedCompletion:(void(^)(EditorViewControllerType newType))typePickedCompletion;

@end
