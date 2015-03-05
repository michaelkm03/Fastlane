//
//  VDependencyManager+VNavigationItem.m
//  victorious
//
//  Created by Josh Hinman on 2/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VNavigationMenuItem.h"
#import "VNavigationDestination.h"
#import "VRootViewController.h"
#import <Objc/runtime.h>

NSString * const VDependencyManagerTitleImageKey = @"titleImage";

static const char kAssociatedObjectKey;

@implementation VDependencyManager (VNavigationItem)

- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem
{
    [self addPropertiesToNavigationItem:navigationItem
               pushAccessoryMenuItemsOn:nil];
}

- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem
             pushAccessoryMenuItemsOn:(UINavigationController *)navigationController
{
    NSString *title = [self stringForKey:VDependencyManagerTitleKey];
    if ( title != nil )
    {
        navigationItem.title = title;
    }
    
    UIImage *titleImage = [self imageForKey:VDependencyManagerTitleImageKey];
    if ( titleImage != nil )
    {
        navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    }
    
    if (navigationController != nil)
    {
        objc_setAssociatedObject(self, &kAssociatedObjectKey, navigationController, OBJC_ASSOCIATION_ASSIGN);
        VNavigationMenuItem *menuItem = [[self accessoryMenuItems] firstObject];
        if ( menuItem != nil )
        {
            UIBarButtonItem *accessoryBarItem = [[UIBarButtonItem alloc] initWithImage:menuItem.icon style:UIBarButtonItemStylePlain target:self action:@selector(showAccessoryMenuItemOnNavigation)];
            navigationItem.leftBarButtonItem = accessoryBarItem;
        }
    }
}

- (void)showAccessoryMenuItemOnNavigation
{
    UINavigationController *navigationController = objc_getAssociatedObject(self, &kAssociatedObjectKey);
    
    VNavigationMenuItem *menuItem = [[self accessoryMenuItems] firstObject];
    UIViewController *destination = nil;
    if ([((id <VNavigationDestination>)menuItem.destination) shouldNavigateWithAlternateDestination:&destination])
    {
        [navigationController pushViewController:menuItem.destination animated:YES];
    }
    
}

@end
