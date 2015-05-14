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
#import "VAuthorizationContextProvider.h"
#import "VAuthorizedAction.h"
#import "VObjectManager.h"
#import "VBarButton.h"

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
    
    if ( navigationController != nil && self.accessoryMenuItems.count > 0 )
    {
            
        objc_setAssociatedObject(self, &kAssociatedObjectKey, navigationController, OBJC_ASSOCIATION_ASSIGN);
        
        //NSMutableArray *barButtonItemsLeft = [[NSMutableArray alloc] initWithArray:navigationItem.leftBarButtonItems];
        //NSMutableArray *barButtonItemsRight = [[NSMutableArray alloc] initWithArray:navigationItem.rightBarButtonItems];
        NSMutableArray *barButtonItemsLeft = [[NSMutableArray alloc] init];
        NSMutableArray *barButtonItemsRight = [[NSMutableArray alloc] init];
        id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)navigationController.topViewController;
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
                // If an icon is provided, a badge
                NSDictionary *configuration = @{ VHamburgerButtonIconKey : menuItem.icon };
                VBarButton *barButton = [VBarButton newWithDependencyManager:[self childDependencyManagerWithAddedConfiguration:configuration]];
                [barButton addTarget:self action:@selector(showAccessoryMenuItemOnNavigation:)
                    forControlEvents:UIControlEventTouchUpInside];
                
                id<VNavigationDestination> destination = (id<VNavigationDestination>)menuItem.destination;
                if ( [destination respondsToSelector:@selector(badgeNumber)] )
                {
                    barButton.badgeNumber = [destination badgeNumber];
                }
                
                accessoryBarItem = [[UIBarButtonItem alloc] initWithCustomView:barButton];
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
            
            if ( [menuItem.position isEqualToString:VDependencyManagerPositionRight] &&
                 ![self barButtonItemsArray:barButtonItemsRight containsMenuItem:menuItem] )
            {
                [barButtonItemsRight addObject:accessoryBarItem];
            }
            else if ( ([menuItem.position isEqualToString:VDependencyManagerPositionLeft] || menuItem.position == nil) &&
                      ![self barButtonItemsArray:barButtonItemsLeft containsMenuItem:menuItem] )
            {
                [barButtonItemsLeft addObject:accessoryBarItem];
            }
        }
        
        NSInteger tag = 0;
        for ( UIBarButtonItem *accessoryBarItem in [barButtonItemsLeft arrayByAddingObjectsFromArray:barButtonItemsRight] )
        {
            accessoryBarItem.tag = tag++;
        }
        
        navigationItem.leftBarButtonItems = barButtonItemsLeft;
        navigationItem.rightBarButtonItems = barButtonItemsRight;
    }
}

- (BOOL)barButtonItemsArray:(NSArray *)barButtonItems containsMenuItem:(VNavigationMenuItem *)menuItem
{
    for ( UIBarButtonItem *barButtonItem in barButtonItems )
    {
        if ( [barButtonItem.title isEqualToString:menuItem.title] || [barButtonItem.image isEqual:menuItem.icon] )
        {
            return YES;
        }
    }
    return NO;
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

    BOOL canNavigationToDestination = destination != nil && ![destination isKindOfClass:[NSNull class]];
    if ( [destination conformsToProtocol:@protocol(VNavigationDestination)] )
    {
        canNavigationToDestination = [destination shouldNavigateWithAlternateDestination:&destination];
    }
    
    id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)navigationController.topViewController;
    
    id <VAuthorizationContextProvider> authorizedDestination = (id <VAuthorizationContextProvider>)destination;
    BOOL requiresAuthorization = [authorizedDestination conformsToProtocol:@protocol(VAuthorizationContextProvider)] &&
                                 authorizedDestination.requiresAuthorization;
    
    if ( requiresAuthorization )
    {
        VAuthorizationContext context = [authorizedDestination authorizationContext];
        VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                             dependencyManager:self];
        [authorizedAction performFromViewController:navigationController context:context completion:^(BOOL authorized)
         {
             if ( authorized && canNavigationToDestination )
             {
                 [self performNavigationFromSource:source toDestination:destination inNavigationController:navigationController];
             }
         }];
    }
    else if ( canNavigationToDestination )
    {
        [self performNavigationFromSource:source toDestination:destination inNavigationController:navigationController];
    }
}

- (void)performNavigationFromSource:(id<VAccessoryNavigationSource>)source
                       toDestination:(UIViewController *)destination
              inNavigationController:(UINavigationController *)navigationController
{
    BOOL shouldNavigate = YES;
    if ( [source respondsToSelector:@selector(willNavigationToDestination:)] )
    {
        shouldNavigate = [source willNavigationToDestination:destination];
    }
    if ( shouldNavigate )
    {
        [navigationController pushViewController:destination animated:YES];
    }
}

@end
