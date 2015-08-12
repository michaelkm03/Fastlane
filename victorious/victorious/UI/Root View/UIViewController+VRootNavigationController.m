//
//  UIViewController+VRootNavigationController.m
//  victorious
//
//  Created by Michael Sena on 8/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIViewController+VRootNavigationController.h"
#import "VTabScaffoldViewController.h"

@implementation UIViewController (VRootNavigationController)

- (UINavigationController *)rootNavigationController
{
    UINavigationController *rootNavigationController = [self recursiveRootViewControllerSearch];
    
    return rootNavigationController;
}

- (UINavigationController *)recursiveRootViewControllerSearch
{
    // Recursively search up the viewController hierarchy for the viewController whose parent
    // is VTabScaffold. This is the root navigation controller.
    UIViewController *parentViewController = self.parentViewController;
    if ([parentViewController isKindOfClass:[VTabScaffoldViewController class]])
    {
        return (UINavigationController *)self;
    }
    else if (parentViewController == nil)
    {
        return nil;
    }
    else
    {
        return [parentViewController recursiveRootViewControllerSearch];
    }
}

@end
