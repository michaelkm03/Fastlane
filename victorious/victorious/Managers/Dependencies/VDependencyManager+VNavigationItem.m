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
        navigationItem.title = NSLocalizedString(title, @"");
    }
    
    UIImage *titleImage = [self imageForKey:VDependencyManagerTitleImageKey];
    if ( titleImage != nil )
    {
        navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    }
    
    if (navigationController != nil)
    {
        objc_setAssociatedObject(self, &kAssociatedObjectKey, navigationController, OBJC_ASSOCIATION_ASSIGN);
        NSInteger tag = 0;
        NSMutableArray *barButtonItemsLeft = [[NSMutableArray alloc] init];
        NSMutableArray *barButtonItemsRight = [[NSMutableArray alloc] init];
        for ( VNavigationMenuItem *menuItem in self.accessoryMenuItems )
        {
            UIBarButtonItem *accessoryBarItem = [[UIBarButtonItem alloc] initWithImage:menuItem.icon
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(showAccessoryMenuItemOnNavigation:)];
            accessoryBarItem.tag = tag++;
            if ( [menuItem.position isEqualToString:VDependencyManagerPositionRight])
            {
                [barButtonItemsRight addObject:accessoryBarItem];
            }
            else if ( [menuItem.position isEqualToString:VDependencyManagerPositionLeft] || menuItem.position == nil )
            {
                [barButtonItemsLeft addObject:accessoryBarItem];
            }
        }
        
        navigationItem.leftBarButtonItems = [barButtonItemsLeft arrayByAddingObjectsFromArray:navigationItem.leftBarButtonItems];
        navigationItem.rightBarButtonItems = [barButtonItemsRight arrayByAddingObjectsFromArray:navigationItem.rightBarButtonItems];
    }
}

- (void)showAccessoryMenuItemOnNavigation:(UIBarItem *)barButton
{
    NSInteger selectedIndex = barButton.tag;
    if ( selectedIndex < 0 || selectedIndex >= (NSInteger)self.accessoryMenuItems.count )
    {
        return;
    }
    
    VNavigationMenuItem *menuItem = self.accessoryMenuItems[ selectedIndex ];
    UINavigationController *navigationController = objc_getAssociatedObject(self, &kAssociatedObjectKey);
    [navigationController pushViewController:menuItem.destination animated:YES];
    
}

@end
