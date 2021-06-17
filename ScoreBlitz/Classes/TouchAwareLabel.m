//
// Created by Moritz Pfeiffer on 24/03/15.
//

#import "TouchAwareLabel.h"


@implementation TouchAwareLabel

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.touchesBegan) {
        self.touchesBegan(self);
    }
}
@end