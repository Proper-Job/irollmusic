//
//  BrowserViewController.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.03.13.
//
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@end

@implementation BrowserViewController

- (id)initWithURL:(NSURL *)theUrl dismissBlock:(BrowserDismissBlock)theDismissBlock
{
    self = [super initWithNibName:@"BrowserViewController" bundle:nil];
    if (self) {
        self.url = theUrl;
        self.dismissBlock = theDismissBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topToolbar.delegate = self;
    
    self.dismissButtonItem.title = MyLocalizedString(@"buttonDone", nil);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (kCFURLErrorNotConnectedToInternet == error.code) {
        [self.webView loadHTMLString:@"" baseURL:nil];
        
        UIAlertController *alertController = [Helpers alertControllerWithTitle:nil message:[error localizedDescription]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)dismiss:(id)sender
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
