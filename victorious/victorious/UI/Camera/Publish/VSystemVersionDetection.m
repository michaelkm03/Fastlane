//
//  VSystemVersionDetection.m
//

#import "NSArray+VMap.h"
#import "VSystemVersionDetection.h"

@implementation VSystemVersionDetection

+ (NSInteger)majorVersionNumber
{
    NSArray *parts = [self systemVersionParts];
    if (parts.count > 0)
    {
        return [parts[0] integerValue];
    }
    else
    {
        return 0;
    }
}

+ (NSInteger)minorVersionNumber
{
    NSArray *parts = [self systemVersionParts];
    if (parts.count >= 1)
    {
        return [parts[1] integerValue];
    }
    else
    {
        return 0;
    }
}

+ (NSInteger)patchNumber
{
    NSArray *parts = [self systemVersionParts];
    if (parts.count >= 2)
    {
        return [parts[2] integerValue];
    }
    else
    {
        return 0;
    }
}

+ (NSArray *)systemVersionParts
{
    return [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
}

@end
