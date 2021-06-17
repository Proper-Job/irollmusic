//
//  HelpViewController.m
//  ScoreBlitz
//
//  Created by Max Pfeiffer on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpViewPopOverViewController.h"
#import "BrowserViewController.h"

@implementation HelpViewController

- (id)initWithControlItems:(NSArray *)items
                 templates:(NSArray *)templates
              mainTemplate:(NSString *)mainTemplate
              tutorialType:(TutorialType)theType
                completion:(void(^)(void))completion

{
    self = [super initWithNibName:@"HelpViewController" bundle:nil];
    if (self) {
        self.completion = completion;
        self.controlItems = [[NSMutableArray alloc] initWithArray:items];
        self.templates = [[NSMutableArray alloc] initWithArray:templates];
        self.mainTemplate = mainTemplate;
        self.tutorialType = theType;
        
        [self addHelpToControls];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.scrollView.bounces = NO;
    self.centerHelpView.clipsToBounds = YES;
    self.webView.clipsToBounds = YES;
    self.centerHelpView.layer.borderWidth = 1.0;
    self.centerHelpView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    self.centerHelpView.layer.masksToBounds = NO;
    self.centerHelpView.layer.shadowOffset = CGSizeMake(3, 3);
    self.centerHelpView.layer.shadowOpacity = 0.5;
    self.centerHelpView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.centerHelpView.bounds].CGPath;
    
    
    UIImage *buttonBackgroundImage = [Helpers imageFromColor:[Helpers petrol]];
    
    [self.tutorialButton setTitle:MyLocalizedString(@"helpViewControllerTutorialButton", nil) forState:UIControlStateNormal];
    [self.tutorialButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    
    [self.doneButton setTitle:MyLocalizedString(@"buttonDone", nil) forState:UIControlStateNormal];
    [self.doneButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    
    self.leftTapZoneLabel.text = MyLocalizedString(@"helpPagingPerformanceLeftTapZone", nil);
    self.rightTapZoneLabel.text = MyLocalizedString(@"helpPagingPerformanceRightTapZone", nil);

    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:self.mainTemplate
                                                                      ofType:@"html"
                                                                 inDirectory:@"help_templates"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    if (TutorialTypePagingPerformance == self.tutorialType) {
        self.leftTapZoneView.backgroundColor = [[Helpers black] colorWithAlphaComponent:.3];
        self.leftTapZoneView.layer.borderWidth = 1.0;
        self.leftTapZoneView.layer.borderColor = [Helpers black].CGColor;
        self.leftTapZoneView.layer.cornerRadius = 3.0;
        
        self.rightTapZoneView.backgroundColor = [[Helpers black] colorWithAlphaComponent:.3];
        self.rightTapZoneView.layer.borderWidth = 1.0;
        self.rightTapZoneView.layer.borderColor = [Helpers black].CGColor;
        self.rightTapZoneView.layer.cornerRadius = 3.0;
    }else {
        self.leftTapZoneView.hidden = YES;
        self.rightTapZoneView.hidden = YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)dissmissHelpViewController
{
    // dissmiss popovers
    if (self.popOverViewController != nil) {
        [self.popOverViewController dismissPopoverAnimated:NO];
    }
    
    // set cached targets and actions
    for (id item in self.controlItems) {
        NSDictionary *dict = self.targetsAndSelectorsOfControlItems[[self.controlItems indexOfObject:item]];
        if ([item isKindOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem *i = (UIBarButtonItem *)item;
            [i setTarget:dict[kTargetKey]];
            [i setAction: NSSelectorFromString(dict[kSelectorKey])];
        } else if ([item isKindOfClass:[UIButton class]]) {
            [item removeTarget:self action:@selector(buttonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
            [item addTarget:[dict objectForKey:kTargetKey] action:NSSelectorFromString([dict objectForKey:kSelectorKey]) forControlEvents:UIControlEventTouchUpInside];
        } else if ([item isKindOfClass:[UISegmentedControl class]]) {
            [item removeTarget:self action:@selector(buttonTapped:withEvent:) forControlEvents:UIControlEventValueChanged];
            [item addTarget:[dict objectForKey:kTargetKey] action:NSSelectorFromString([dict objectForKey:kSelectorKey]) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    // kill view end send finish message
    [UIView animateWithDuration:kHelpViewControllerFadeAnimationDuration
                     animations:^(void) {
                         self.view.alpha = 0;
                     } completion:^(BOOL finished) {
                         //[self.view removeFromSuperview];
                         //[self.delegate helpViewControllerDidDissmissHelpView:self];
                         if (self.completion) {
                             self.completion();
                         }
                     }];
}

#pragma mark - Button actions

- (IBAction)tutorialButtonTapped
{
    NSURL *url = [Helpers localizedTutorialMovieUrlForTutorialType:self.tutorialType];
    if (nil != url) {
        BrowserViewController *browser = [[BrowserViewController alloc] initWithURL:url dismissBlock:NULL];
        browser.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:browser
                           animated:YES
                         completion:NULL];
    }
}

- (IBAction)doneButtonTapped
{
    [self dissmissHelpViewController];
}

#pragma mark - Help Interface

- (void)addHelpToControls
{
    if ([self.controlItems count] == [self.templates count]) {
        // cache controlItems and descriptions
        self.targetsAndSelectorsOfControlItems = [NSMutableArray array];
           
        for (id item in self.controlItems) {
            // cache targets and selectors
            if ([item isKindOfClass:[UIBarButtonItem class]]) {
                UIBarButtonItem *i = (UIBarButtonItem *)item;
                [self.targetsAndSelectorsOfControlItems addObject:@{kTargetKey: [item target],
                                                                    kSelectorKey: NSStringFromSelector([i action])}];
                // set new targets and selectors
                [i setTarget:self];
                [i setAction:@selector(buttonTapped:withEvent:)];
            } else if ([item isKindOfClass:[UIButton class]]) {
                // cache targets and selectors                
                NSSet *setOfTargets = [item allTargets];
                if ([setOfTargets count] == 1) {
                    id target = [setOfTargets anyObject];
                    NSArray *actions = [item actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
                    if ([actions count] == 1) {
                        NSString *action = [actions lastObject];
                        [self.targetsAndSelectorsOfControlItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:target, kTargetKey, action, kSelectorKey , nil]];
                        // remove old and set new targets and selectors
                        [item removeTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                        [item addTarget:self action:@selector(buttonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
            } else if ([item isKindOfClass:[UISegmentedControl class]]) {
                // cache targets and selectors                
                NSSet *setOfTargets = [item allTargets];
                if ([setOfTargets count] == 1) {
                    id target = [setOfTargets anyObject];
                    NSArray *actions = [item actionsForTarget:target forControlEvent:UIControlEventValueChanged];
                    if ([actions count] == 1) {
                        NSString *action = [actions lastObject];
                        [self.targetsAndSelectorsOfControlItems addObject:@{kTargetKey : target, kSelectorKey : action}];
                        // remove old and set new targets and selectors
                        [item removeTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventValueChanged];
                        [item addTarget:self action:@selector(buttonTapped:withEvent:) forControlEvents:UIControlEventValueChanged];
                    }
                }
            }
        }
    }
}

- (void)buttonTapped:(UIControl *)controlItem withEvent:(UIEvent *)event
{
    if (self.popOverViewController != nil) {
        [self.popOverViewController dismissPopoverAnimated:YES];
        self.popOverViewController.delegate = nil;
        self.popOverViewController = nil;
    }
    
    NSInteger index = [self.controlItems indexOfObject:controlItem];
    HelpViewPopOverViewController *helpController = [[HelpViewPopOverViewController alloc] initWithTemplate:self.templates[index]
                                                                                                controlItem:controlItem
                                                                                        webViewFinishedLoad:^(id item)
    {
        NSInteger theIndex = [self.controlItems indexOfObject:item];

        if ([item isKindOfClass:[UIBarButtonItem class]]) {
            [self.popOverViewController presentPopoverFromBarButtonItem:self.controlItems[theIndex]
                                               permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                                               animated:YES];
        } else if ([item isKindOfClass:[UIButton class]]) {
            [self.popOverViewController presentPopoverFromRect:[[item superview] frame]
                                                        inView:[[item superview] superview]
                                      permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                                      animated:YES];
        } else if ([item isKindOfClass:[UISegmentedControl class]]) {
            [self.popOverViewController presentPopoverFromRect:[item frame]
                                                        inView:[item superview]
                                      permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                                      animated:YES];
        }
    }];

    self.popOverViewController = [[UIPopoverController alloc] initWithContentViewController:helpController];
    self.popOverViewController.delegate = self;
    [helpController loadContent];
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([popoverController isEqual:self.popOverViewController]) {
        self.popOverViewController.delegate = nil;
        self.popOverViewController = nil;
    }
}

@end
