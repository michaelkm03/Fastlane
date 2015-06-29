//
//  VDependencyManager+VKeyboardStyle.m
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VKeyboardStyle.h"

NSString * const VKeyboardStyleKey = @"keyboardStyle";

static NSString * const kLightKeyboardStyle = @"light";
static NSString * const kDarkKeyboardStyle = @"dark";

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
