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
        id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)navigationController.topViewController;
            
        objc_setAssociatedObject(self, &kAssociatedObjectKey, navigationController, OBJC_ASSOCIATION_ASSIGN);
        NSInteger tag = 0;
        NSMutableArray *barButtonItemsLeft = [[NSMutableArray alloc] init];
        NSMutableArray *barButtonItemsRight = [[NSMutableArray alloc] init];
        for ( VNavigationMenuItem *menuItem in self.accessoryMenuItems )
        {
            // Check if the source can display the menu item (default is YES)
            if ( [source conformsToProtocol:@protocol(VAccessoryNavigationSource)] &&
                 [source respondsToSelector:@selector(shouldDisplayAccessoryForDestination:)] )
            {
                if ( ![source shouldDisplayAccessoryForDestination:menuItem.destination] )
                {
                    continue;
                }
            }
            
            UIBarButtonItem *accessoryBarItem = nil;
            if ( menuItem.icon != nil )
            {
                accessoryBarItem = [[UIBarButtonItem alloc] initWithImage:menuItem.icon
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(showAccessoryMenuItemOnNavigation:)];
            }
            else if ( menuItem.title != nil )
            {
                accessoryBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( menuItem.title, @"" )
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(showAccessoryMenuItemOnNavigation:)];
            }
            else
            {
                continue;
            }
            
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
        
        navigationItem.leftBarButtonItems = barButtonItemsLeft;
        navigationItem.rightBarButtonItems = barButtonItemsRight;
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
    UIViewController<VNavigationDestination> *destination = menuItem.destination;
    
    BOOL canNavigateFromSource = YES;
    id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)navigationController.topViewController;
    if ( [source conformsToProtocol:@protocol(VAccessoryNavigationSource)] )
    {
        canNavigateFromSource = [source shouldNavigateToDestination:menuItem.destination];
    }

    BOOL canNavigationToDestination = YES;
    if ( [destination conformsToProtocol:@protocol(VNavigationDestination)] )
    {
        canNavigationToDestination = [destination shouldNavigateWithAlternateDestination:&destination];
    }
    
    if ( canNavigateFromSource && canNavigationToDestination )
    {
        [navigationController pushViewController:destination animated:YES];
    }
}

@end
