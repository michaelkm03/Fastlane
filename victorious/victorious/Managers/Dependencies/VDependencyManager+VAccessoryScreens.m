//
//  VDependencyManager+VAccessoryScreens.m
//  victorious
//
//  Created by Patrick Lynch on 6/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <objc/runtime.h>
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VNavigationMenuItem.h"
#import "VNavigationDestination.h"
#import "UIResponder+VResponderChain.h"
#import "VMenuItemControl.h"
#import "victorious-Swift.h"

/**
 A UIBarButtonItem subclass used primarily to attach the `menuItemIdentifier` property
 so that the same instance can be retreived from the navigation item when selected by the user.
 */
@interface VBarButtonItem : UIBarButtonItem

@property (nonatomic, strong) VNavigationMenuItem *menuItem; ///< The identifier from the VNavigationMenuItem used to create this instance

@end

@implementation VBarButtonItem

@end

static const char kAssociatedObjectSourceViewControllerKey;

@implementation VDependencyManager (VAccessoryScreens)

- (void)addAccessoryScreensToNavigationItem:(UINavigationItem *)navigationItem
                           fromViewController:(UIViewController *)sourceViewController
{
    objc_setAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey, sourceViewController, OBJC_ASSOCIATION_ASSIGN );
    
    NSOrderedSet *accessoryMenuItems = [self accessoriesForSource:sourceViewController];
    
    NSMutableArray *newBarButtonItemsLeft = [[NSMutableArray alloc] init];
    NSMutableArray *newBarButtonItemsRight = [[NSMutableArray alloc] init];
    
    for ( VNavigationMenuItem *menuItem in accessoryMenuItems )
    {
        VBarButtonItem *accessoryBarItem = nil;
        
        if ( menuItem.icon != nil )
        {
            // If an icon is provided, a badge
            VBarButton *barButton = [VBarButton newWithDependencyManager:self];
            [barButton setImage:menuItem.icon];
            [barButton setTintColor:menuItem.tintColor];
            [barButton addTarget:self action:@selector(accessoryMenuItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            barButton.menuItem = menuItem;
            
            accessoryBarItem = [[VBarButtonItem alloc] initWithCustomView:barButton];
            accessoryBarItem.menuItem = menuItem;
            accessoryBarItem.tintColor = menuItem.tintColor;
            accessoryBarItem.accessibilityLabel = menuItem.identifier;
        }
        else if ( menuItem.title != nil )
        {
            accessoryBarItem = [[VBarButtonItem alloc] initWithTitle:menuItem.title
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(accessoryMenuItemSelected:)];
            accessoryBarItem.menuItem = menuItem;
            accessoryBarItem.tintColor = menuItem.tintColor;
            accessoryBarItem.accessibilityLabel = menuItem.identifier;
        }
        
        if ( accessoryBarItem == nil )
        {
            continue;
        }
        
        if ( [menuItem.position isEqualToString:VDependencyManagerPositionRight] )
        {
            [newBarButtonItemsRight addObject:accessoryBarItem];
        }
        else if ( ([menuItem.position isEqualToString:VDependencyManagerPositionLeft] || menuItem.position == nil) )
        {
            [newBarButtonItemsLeft addObject:accessoryBarItem];
        }
    }
    
    if ([sourceViewController conformsToProtocol:@protocol(AccessoryScreenContainer)])
    {
        id<AccessoryScreenContainer> container = (id<AccessoryScreenContainer>)sourceViewController;
        newBarButtonItemsLeft = [[container addCustomLeftItemsTo:newBarButtonItemsLeft] mutableCopy];
        newBarButtonItemsRight = [[container addCustomRightItemsTo:newBarButtonItemsRight] mutableCopy];
    }
    
    BOOL shouldAnimate;
    
    navigationItem.leftItemsSupplementBackButton = YES;
    
    shouldAnimate = newBarButtonItemsLeft.count != navigationItem.leftBarButtonItems.count;
    [navigationItem setLeftBarButtonItems:newBarButtonItemsLeft animated:shouldAnimate];
    
    shouldAnimate = newBarButtonItemsRight.count != navigationItem.rightBarButtonItems.count;
    [navigationItem setRightBarButtonItems:newBarButtonItemsRight animated:shouldAnimate];
}

- (NSOrderedSet *)accessoriesForSource:(UIResponder *)source
{
    __block NSMutableOrderedSet *accessoryMenuItems = [[NSMutableOrderedSet alloc] init];
    
    // Walk the responder chain and collect accessoryMenuItems from each responders dependencyManager
    [source v_walkWithBlock:^(UIResponder *responder, BOOL *stop)
     {
         id<VNavigationDestination> destination = (id<VNavigationDestination>)responder;
         
         NSString *accessoryScreensKey = nil;
         // Does this point in the responder chain provide a custom accessory screens key?
         if ([destination conformsToProtocol:@protocol(AccessoryScreenContainer)])
         {
             accessoryScreensKey = [(id<AccessoryScreenContainer>)destination accessoryScreensKey];
         }
         
         if ([destination respondsToSelector:@selector(dependencyManager)])
         {
             [accessoryMenuItems addObjectsFromArray:[[destination dependencyManager] accessoryMenuItemsWithKey:accessoryScreensKey]];
         }
     }];
    
    return [[NSOrderedSet alloc] initWithOrderedSet:accessoryMenuItems];
}

- (NSString *)identifierForAccessoryBarButton:(UIResponder *)source
{
    UIResponder *responder = source;
    do
    {
        if ( [responder isKindOfClass:[VBarButton class]] )
        {
            VBarButton *barButton = (VBarButton *)responder;
            return ((VNavigationMenuItem *)barButton.menuItem).identifier;
        }
        else if ( [responder isKindOfClass:[VBarButtonItem class]] )
        {
            VBarButtonItem *barButtonItem = (VBarButtonItem *)responder;
            return barButtonItem.menuItem.identifier;
        }
        else if ( [responder isKindOfClass:[VMenuItemControl class]] )
        {
            VMenuItemControl *customControl = (VMenuItemControl *)responder;
            return customControl.menuItem.identifier;
        }
        
    }
    while (( responder = [responder nextResponder] ));
    return nil;
}

- (VNavigationMenuItem *)menuItemWithIdentifier:(NSString *)identifier
{
    UINavigationController *sourceViewController = objc_getAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey );
    NSOrderedSet *accessoryMenuItems = [self accessoriesForSource:sourceViewController];
    
    for ( VNavigationMenuItem *menuItem in accessoryMenuItems )
    {
        if ( [menuItem.identifier isEqualToString:identifier] )
        {
            return menuItem;
        }
    }
    return nil;
}

- (void)accessoryMenuItemSelected:(id)sender
{
    NSString *selectMenuItemIdentifier = [self identifierForAccessoryBarButton:sender];
    NSAssert( selectMenuItemIdentifier != nil, @"Cannot find navigation menu item from selected bar item." );
    [self navigateToDestinationForMenuItemIdentifier:selectMenuItemIdentifier];
}

- (BOOL)navigateToDestinationForMenuItemIdentifier:(NSString *)menuItemIdentifier
{
    VNavigationMenuItem *menuItem = [self menuItemWithIdentifier:menuItemIdentifier];
    if ( menuItem == nil )
    {
        return NO;
    }
    
    UINavigationController *sourceViewController = objc_getAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey );
    [self performNavigationFromSource:sourceViewController withMenuItem:menuItem];
    
    return YES;
}

- (void)performNavigationFromSource:(UIViewController *)sourceViewController withMenuItem:(VNavigationMenuItem *)menuItem
{
    BOOL isValidNavController = sourceViewController.navigationController != nil;
    BOOL isNotOnNavigationStack = ![sourceViewController.navigationController.viewControllers containsObject:menuItem.destination];
    
    if (menuItem.hasValidDestination && isValidNavController && isNotOnNavigationStack)
    {
        [sourceViewController.navigationController pushViewController:menuItem.destination animated:YES];
    }
}

@end
