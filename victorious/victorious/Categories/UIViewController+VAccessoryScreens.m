//
//  UIViewController+VAccessoryScreens.m
//  victorious
//
//  Created by Sharif Ahmed on 7/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIViewController+VAccessoryScreens.h"
#import "VDependencyManager+VAccessoryScreens.h"

@implementation UIViewController (VAccessoryScreens)

- (void)v_addAccessoryScreensWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UINavigationItem *navigationItem = [self navigationItemForAccessoryItems];
    [dependencyManager addAccessoryScreensToNavigationItem:navigationItem fromViewController:self];
}

- (UINavigationItem *)navigationItemForAccessoryItems
{
    return self.navigationItem;
}

@end
