//
//  HelpViewPopOverViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpViewPopOverViewController.h"
#import "ALView+PureLayout.h"

@implementation HelpViewPopOverViewController


- (id)initWithTemplate:(NSString *)templateName
           controlItem:(id)theControlItem
   webViewFinishedLoad:(void(^)(id controlItem))webViewFinishedLoad
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.templateName = templateName;
        self.controlItem = theControlItem;
        self.webViewFinishedLoad = webViewFinishedLoad;
    }
    return self;
}

- (void)loadContent
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView autoPinEdgesToSuperviewEdgesWithInsets:ALEdgeInsetsMake(0,0,0,0)];
    
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:self.templateName
                                                                      ofType:@"html"
                                                                 inDirectory:@"help_templates"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *bodyHeight = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"];
    NSString *bodyWidth = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetWidth"];

    self.preferredContentSize = CGSizeMake([bodyWidth floatValue], [bodyHeight floatValue]);
    if (self.webViewFinishedLoad) {
        self.webViewFinishedLoad(self.controlItem);
    }
}



@end
