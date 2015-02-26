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

NSString * const VDependencyManagerTitleImageKey = @"titleImage";

@implementation VDependencyManager (VNavigationItem)

- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem
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
    
    VNavigationMenuItem *menuItem = [[self accessoryMenuItems] firstObject];
    if ( menuItem != nil )
    {
        UIBarButtonItem *accessoryBarItem = [[UIBarButtonItem alloc] initWithImage:menuItem.icon style:UIBarButtonItemStylePlain target:self action:@selector(showAccessoryMenuItem)];
//TODO: Change target
        navigationItem.leftBarButtonItem = accessoryBarItem;
    }
}

//TODO: Remove me 
- (void)showAccessoryMenuItem
{
    VNavigationMenuItem *menuItem = [[self accessoryMenuItems] firstObject];
    UIViewController *destination = nil;
    if ([((id <VNavigationDestination>)menuItem.destination) shouldNavigateWithAlternateDestination:&destination])
    {
        [[VRootViewController rootViewController] presentViewController:destination animated:YES completion:nil];
    }
    
}

@end
