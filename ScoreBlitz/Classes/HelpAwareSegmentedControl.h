//
//  HelpAwareSegmentedControl.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HelpViewController;

@interface HelpAwareSegmentedControl : UISegmentedControl {
    
}

@property (nonatomic, weak) HelpViewController *helpController;

@end
