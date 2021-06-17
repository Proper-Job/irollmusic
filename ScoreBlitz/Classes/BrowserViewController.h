//
//  BrowserViewController.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.03.13.
//
//

#import <UIKit/UIKit.h>

typedef void (^BrowserDismissBlock)(void);

@interface BrowserViewController : UIViewController <UIWebViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *dismissButtonItem;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) BrowserDismissBlock dismissBlock;

- (id)initWithURL:(NSURL *)theUrl dismissBlock:(BrowserDismissBlock)theDismissBlock;
- (IBAction)dismiss:(id)sender;


@end
