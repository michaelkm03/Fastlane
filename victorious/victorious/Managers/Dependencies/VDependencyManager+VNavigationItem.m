//
//  VDependencyManager+VNavigationItem.m
//  victorious
//
//  Created by Josh Hinman on 2/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <objc/runtime.h>
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VNavigationMenuItem.h"
#import "VNavigationDestination.h"
#import "VAuthorizationContextProvider.h"
#import "VAuthorizedAction.h"
#import "VObjectManager.h"
#import "UIResponder+VResponderChain.h"
#import "VProvidesNavigationMenuItemBadge.h"

/**
 A UIBarButtonItem subclass used primarily to attach the `menuItemIdentifier` property
 so that the same instance can be retreived from the navigation item when selected by the user.
 */
@interface VBarButtonItem : UIBarButtonItem

@property (nonatomic, strong) VNavigationMenuItem *menuItem; ///< The identifier from the VNavigationMenuItem used to create this instance

@end

@implementation VBarButtonItem

@end

NSString * const VDependencyManagerTitleImageKey                = @"titleImage";

NSString * const VDependencyManagerAccessoryItemMenu            = @"Accessory Menu";
NSString * const VDependencyManagerAccessoryItemCompose         = @"Accessory Compose";
NSString * const VDependencyManagerAccessoryItemInbox           = @"Accessory Inbox";
NSString * const VDependencyManagerAccessoryItemFindFriends     = @"Accessory Find Friends";
NSString * const VDependencyManagerAccessoryItemInvite          = @"Accessory Invite";
NSString * const VDependencyManagerAccessoryItemCreatePost      = @"Accessory Create Post";
NSString * const VDependencyManagerAccessoryItemFollowHashtag   = @"Accessory Follow Hashtag";
NSString * const VDependencyManagerAccessoryItemMore            = @"Accessory More";

static const char kAssociatedObjectSourceViewControllerKey;

@interface VDependencyManager()

@property (nonatomic, strong) VDependencyManager *parentManager;

@end

@implementation VDependencyManager (VNavigationItem)

- (void)configureNavigationItem:(UINavigationItem *)navigationItem
{
    [self configureNavigationItem:navigationItem forViewController:nil];
}

- (void)configureNavigationItem:(UINavigationItem *)navigationItem
              forViewController:(UIViewController *)sourceViewController
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
    
    objc_setAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey, sourceViewController, OBJC_ASSOCIATION_ASSIGN );
    id<VAccessoryNavigationSource> source = nil;
    if ( [sourceViewController conformsToProtocol:@protocol(VAccessoryNavigationSource) ] )
    {
        source = (id<VAccessoryNavigationSource>)sourceViewController;
    }
    
    NSOrderedSet *accessoryMenuItems = [self accessoriesForSource:sourceViewController];
    
    NSMutableArray *newBarButtonItemsLeft = [[NSMutableArray alloc] init];
    NSMutableArray *newBarButtonItemsRight = [[NSMutableArray alloc] init];
    
    for ( VNavigationMenuItem *menuItem in accessoryMenuItems )
    {
        if ( ![self shouldDisplayMenuItem:menuItem fromSourceViewController:sourceViewController] )
        {
            continue;
        }
        
        VBarButtonItem *accessoryBarItem = nil;
        if ( menuItem.icon != nil )
        {
            // If an icon is provided, a badge
            VBarButton *barButton = [VBarButton newWithDependencyManager:self];
            [barButton setImage:menuItem.icon];
            [barButton addTarget:self action:@selector(accessoryMenuItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            barButton.menuItem = menuItem;
            
            id<VProvidesNavigationMenuItemBadge> badgeProvider = menuItem.destination;
            if ( [source respondsToSelector:@selector(customBadgeProvider)] )
            {
                badgeProvider = [source customBadgeProvider];
            }
            [self registerBadgeUpdateBlockWithButton:barButton badgeProvider:badgeProvider];
            
            accessoryBarItem = [[VBarButtonItem alloc] initWithCustomView:barButton];
            accessoryBarItem.menuItem = menuItem;
        }
        else if ( menuItem.title != nil )
        {
            accessoryBarItem = [[VBarButtonItem alloc] initWithTitle:NSLocalizedString( menuItem.title, @"" )
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                              action:@selector(accessoryMenuItemSelected:)];
            accessoryBarItem.menuItem = menuItem;
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
    
    BOOL shouldAnimate;
    
    shouldAnimate = newBarButtonItemsLeft.count != navigationItem.leftBarButtonItems.count;
    [navigationItem setLeftBarButtonItems:newBarButtonItemsLeft animated:shouldAnimate];
    
    shouldAnimate = newBarButtonItemsRight.count != navigationItem.rightBarButtonItems.count;
    [navigationItem setRightBarButtonItems:newBarButtonItemsRight animated:shouldAnimate];
}

- (void)registerBadgeUpdateBlockWithButton:(VBarButton *)barButton badgeProvider:(id<VProvidesNavigationMenuItemBadge>)badgeProvider
{
    __weak typeof (barButton) weakBarButton = barButton;
    
    if ( [badgeProvider conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)] )
    {
        VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock = ^(NSInteger badgeNumber)
        {
            [weakBarButton setBadgeNumber:badgeNumber];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
        };
        
        [badgeProvider setBadgeNumberUpdateBlock:badgeNumberUpdateBlock];
        NSInteger badgeNumber = [badgeProvider badgeNumber];
        badgeNumberUpdateBlock( badgeNumber );
    }
}

- (BOOL)shouldDisplayMenuItem:(VNavigationMenuItem *)menuItem fromSourceViewController:(UIViewController *)sourceViewController
{
    // If anyone in the responder chain can and does say no, then we don't display
    __block BOOL shouldDisplay = YES;
    [sourceViewController v_walkWithBlock:^(UIResponder *responder, BOOL *stop)
     {
         if ( [responder respondsToSelector:@selector(shouldDisplayAccessoryMenuItem:fromSource:)] )
         {
             id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)responder;
             if ( ![source shouldDisplayAccessoryMenuItem:menuItem fromSource:sourceViewController] )
             {
                 shouldDisplay = NO;
                 *stop = YES;
             }
         }
    }];
    return shouldDisplay;
}

- (NSOrderedSet *)accessoriesForSource:(UIResponder *)source
{
    __block NSMutableOrderedSet *accessoryMenuItems = [[NSMutableOrderedSet alloc] init];
    
    // Walk the responder chain and collect accessoryMenuItems from each responders dependencyManager
    [source v_walkWithBlock:^(UIResponder *responder, BOOL *stop)
     {
         id<VHasManagedDependencies> dependenyOwner = (id<VHasManagedDependencies>)responder;
         if ( [dependenyOwner respondsToSelector:@selector(dependencyManager)] )
         {
             [accessoryMenuItems addObjectsFromArray:[dependenyOwner dependencyManager].accessoryMenuItems];
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
    }
    while (( responder = [responder nextResponder] ));
    return nil;
}

- (VBarButton *)barButtonFromNavigationItem:(UINavigationItem *)navigationItme forIdentifier:(NSString *)identifier
{
    UIBarButtonItem *barButtonItem = [self barButtonItemFromNavigationItem:navigationItme forIdentifier:identifier];
    VBarButton *barButton = (VBarButton *)barButtonItem.customView;
    if ( barButton != nil && [barButton isKindOfClass:[VBarButton class]] )
    {
        return barButton;
    }
    return nil;
}

- (UIBarButtonItem *)barButtonItemFromNavigationItem:(UINavigationItem *)navigationItme forIdentifier:(NSString *)identifier
{
    __block VBarButtonItem *foundItem = nil;
    NSPredicate *searchPredicate = [NSPredicate predicateWithBlock:^BOOL(VBarButtonItem *item, NSDictionary *bindings)
    {
        return [item isKindOfClass:[VBarButtonItem class]] && [item.menuItem.identifier isEqualToString:identifier];
    }];
    
    foundItem = [navigationItme.leftBarButtonItems filteredArrayUsingPredicate:searchPredicate].firstObject;
    if ( foundItem != nil )
    {
        return foundItem;
    }
    
    foundItem = [navigationItme.rightBarButtonItems filteredArrayUsingPredicate:searchPredicate].firstObject;
    if ( foundItem != nil )
    {
        return foundItem;
    }
    
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
    
    UIViewController<VNavigationDestination> *destination = menuItem.destination;
    UINavigationController *sourceViewController = objc_getAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey );
    
    BOOL canNavigationToDestination = YES;
    if ( [destination conformsToProtocol:@protocol(VNavigationDestination)] )
    {
        canNavigationToDestination = [destination shouldNavigateWithAlternateDestination:&destination];
    }
    
    BOOL requiresAuthorization = NO;
    VAuthorizationContext context;
    
    // First check if the source requires authorization
    id <VAccessoryNavigationSource> source = (id <VAccessoryNavigationSource>)sourceViewController;
    if ( [source respondsToSelector:@selector(menuItem:requiresAuthorizationWithContext:)] )
    {
        requiresAuthorization = [source menuItem:menuItem requiresAuthorizationWithContext:&context];
    }
    
    // Then check if the desination requires authorization
    id <VAuthorizationContextProvider> authorizedDestination = (id <VAuthorizationContextProvider>)destination;
    if ( !requiresAuthorization &&
         [authorizedDestination conformsToProtocol:@protocol(VAuthorizationContextProvider)] )
    {
        requiresAuthorization = authorizedDestination.requiresAuthorization;
        context = [authorizedDestination authorizationContext];
    }
    
    if ( requiresAuthorization )
    {
        VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                             dependencyManager:self];
        [authorizedAction performFromViewController:sourceViewController context:context completion:^(BOOL authorized)
         {
             if ( authorized && canNavigationToDestination )
             {
                 [self performNavigationFromSource:sourceViewController withMenuItem:menuItem];
             }
         }];
    }
    else if ( canNavigationToDestination )
    {
        [self performNavigationFromSource:sourceViewController withMenuItem:menuItem];
    }
    
    return YES;
}

- (void)performNavigationFromSource:(UIViewController *)sourceViewController withMenuItem:(VNavigationMenuItem *)menuItem
{
    BOOL shouldNavigate = YES;
    UIResponder *responder = sourceViewController;
    do
    {
        id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)responder;
        if ( [source conformsToProtocol:@protocol(VAccessoryNavigationSource)] && ![source shouldNavigateWithAccessoryMenuItem:menuItem] )
        {
            shouldNavigate = NO;
            break;
        }
    }
    while (( responder = [responder nextResponder] ));
    
    BOOL isValidNavController = sourceViewController.navigationController != nil;
    if ( shouldNavigate && menuItem.hasValidDestination && isValidNavController )
    {
        [sourceViewController.navigationController pushViewController:menuItem.destination animated:YES];
    }
}

@end
