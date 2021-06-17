//
//  AirTurnTextView.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 09.12.13.
//
//

#import "AirTurnTextView.h"

@implementation AirTurnTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSOperatingSystemVersion minimumVersion =  (NSOperatingSystemVersion) { .majorVersion = 9, .minorVersion = 0, .patchVersion = 0 };
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:minimumVersion]) {
            self.inputAssistantItem.leadingBarButtonGroups = @[];
            self.inputAssistantItem.trailingBarButtonGroups = @[];
        }
    }
    return self;
}

- (NSArray *) keyCommands
{
    UIKeyCommand *upArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: 0 action: @selector(upArrow:)];
    UIKeyCommand *downArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: 0 action: @selector(downArrow:)];
    UIKeyCommand *leftArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow modifierFlags: 0 action: @selector(leftArrow:)];
    UIKeyCommand *rightArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow modifierFlags: 0 action: @selector(rightArrow:)];
    return [[NSArray alloc] initWithObjects: upArrow, downArrow, leftArrow, rightArrow, nil];
}

- (void) upArrow: (UIKeyCommand *) keyCommand
{
#ifdef DEBUG
    NSLog(@"Up arrow");
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:kAirTurnUpArrowNotification object:self];
}

- (void) downArrow: (UIKeyCommand *) keyCommand
{
#ifdef DEBUG
    NSLog(@"Down arrow");
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:kAirTurnDownArrowNotification object:self];
}

- (void) leftArrow: (UIKeyCommand *) keyCommand
{
#ifdef DEBUG
    NSLog(@"Left arrow");
#endif
}

- (void) rightArrow: (UIKeyCommand *) keyCommand
{
#ifdef DEBUG
    NSLog(@"Right arrow");
#endif
}

@end
