//
//  ToolbarBackButtonView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 25/03/15.
//
//

#import "ToolbarBackButtonView.h"

@implementation ToolbarBackButtonView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.backLabel.text = MyLocalizedString(@"back", nil);
    [[NSNotificationCenter defaultCenter] addObserverForName:kLanguageChanged
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.backLabel.text = MyLocalizedString(@"back", nil);
                                                  }];
}

- (IBAction)backPressed:(id)sender {
    if (self.backPressedBlock) {
        self.backPressedBlock(sender);
    }
}

- (void)dealloc
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *e) {
        ;
    }
}


@end
