//
//  VTabInfo.m
//  victorious
//
//  Created by Josh Hinman on 6/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTabInfo.h"

VTabInfo *v_newTab(UIViewController *viewController, UIImage *icon)
{
    return [[VTabInfo alloc] initWithViewController:viewController icon:icon];
}

@implementation VTabInfo

- (instancetype)initWithViewController:(UIViewController *)viewController icon:(UIImage *)icon
{
    self = [super init];
    if (self)
    {
        _viewController = viewController;
        _icon = icon;
    }
    return self;
}

@end
