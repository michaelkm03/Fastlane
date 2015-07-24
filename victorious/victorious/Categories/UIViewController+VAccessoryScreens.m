//
//  UIViewController+VAccessoryScreens.m
//  victorious
//
//  Created by Sharif Ahmed on 7/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIViewController+VAccessoryScreens.h"
#import "VMultipleContainer.h"
#import "VDependencyManager+VAccessoryScreens.h"

@implementation UIViewController (VAccessoryScreens)

- (void)v_addAccessoryScreensWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UINavigationItem *navigationItem = [self navigationItemForAccessoryItems];
    [dependencyManager addAccessoryScreensToNavigationItem:navigationItem fromViewController:self];
}

- (void)v_addBadgingToAccessoryScreensWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UINavigationItem *navigationItem = [self navigationItemForAccessoryItems];
    [dependencyManager addBadgingToAccessoryScreensInNavigationItem:navigationItem fromViewController:self];
}

- (UINavigationItem *)navigationItemForAccessoryItems
{
    UINavigationItem *navigationItem = self.navigationItem;
    if ( [self conformsToProtocol:@protocol(VMultipleContainerChild)] )
    {
        UIViewController <VMultipleContainerChild> *childViewController = (UIViewController <VMultipleContainerChild> *)self;
        if ( childViewController.multipleContainerChildDelegate != nil )
        {
            navigationItem = [childViewController.multipleContainerChildDelegate parentNavigationItem];
        }
    }
    return navigationItem;
}

@end
