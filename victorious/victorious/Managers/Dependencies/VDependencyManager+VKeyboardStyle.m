//
//  VDependencyManager+VKeyboardStyle.m
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VKeyboardStyle.h"

static NSString *kLightKeyboardStyle = @"light";
static NSString *kDarkKeyboardStyle = @"dark";

@implementation VDependencyManager (VKeyboardStyle)

- (UIKeyboardAppearance)keyboardStyleForKey:(NSString *)key
{
    NSString *stringForKey = [self stringForKey:key];
    if ([stringForKey caseInsensitiveCompare:kDarkKeyboardStyle] == NSOrderedSame)
    {
        return UIKeyboardAppearanceDark;
    }
    else
    {
        return UIKeyboardAppearanceLight;
    }
}

@end
