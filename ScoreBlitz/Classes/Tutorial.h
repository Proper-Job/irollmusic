//
//  Tutorial.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 30.05.14.
//
//

#import <Foundation/Foundation.h>

@interface Tutorial : NSObject

@property (nonatomic, strong) NSString *title, *tutorialDescription;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, assign) TutorialType tutorialType;
@end
