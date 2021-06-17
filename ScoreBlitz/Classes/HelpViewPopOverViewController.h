//
//  HelpViewPopOverViewController.h
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewPopOverViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) id controlItem;
@property (nonatomic, strong) NSString *templateName;
@property (nonatomic, copy) void (^webViewFinishedLoad)(id controlItem);


- (id)initWithTemplate:(NSString *)templateName
       controlItem:(id)theControlItem
   webViewFinishedLoad:(void(^)(id controlItem))webViewFinishedLoad;

- (void)loadContent;
@end
