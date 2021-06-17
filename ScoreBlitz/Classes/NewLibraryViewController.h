//
//  NewLibraryViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 02.09.14.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    LibraryDisplayTypeScores,
    LibraryDisplayTypeSets
}LibraryDisplayType;

@interface NewLibraryViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UISplitViewController *librarySplitViewController;
@property (nonatomic, strong) UIViewController *leftViewController, *rightViewController;

@property (nonatomic, assign) LibraryDisplayType libraryDisplayType;

@end
