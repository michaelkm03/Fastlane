//
//  VDependencyManager+VStatusBarStyle.m
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VStatusBarStyle.h"

static NSString *kLightStatusBarStyle = @"light";
static NSString *kDarkStatusBarStyle = @"dark";

@implementation VDependencyManager (VStatusBarStyle)

- (UIStatusBarStyle)statusBarStyleForKey:(NSString *)key
{
    NSString *stringForKey = [self stringForKey:key];
    if ([stringForKey caseInsensitiveCompare:kLightStatusBarStyle] == NSOrderedSame)
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        return UIStatusBarStyleDefault;
    }
}

@end
