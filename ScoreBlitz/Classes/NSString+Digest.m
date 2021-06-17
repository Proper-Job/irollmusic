#import "NSString+Digest.h"

@implementation NSString (NSString_Digest)



- (NSString *)SHA1
{ 
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

@end
