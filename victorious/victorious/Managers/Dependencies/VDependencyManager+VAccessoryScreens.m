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
#import "VAuthorizationContextProvider.h"
#import "UIResponder+VResponderChain.h"
#import "VProvidesNavigationMenuItemBadge.h"
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

NSString * const VDependencyManagerAccessoryItemMenu            = @"Accessory Menu";
NSString * const VDependencyManagerAccessoryItemCompose         = @"Accessory Compose";
NSString * const VDependencyManagerAccessoryItemInbox           = @"Accessory Inbox";
NSString * const VDependencyManagerAccessoryItemFindFriends     = @"Accessory Find Friends";
NSString * const VDependencyManagerAccessoryItemInvite          = @"Accessory Invite";
NSString * const VDependencyManagerAccessoryItemCreatePost      = @"Accessory Create Post";
NSString * const VDependencyManagerAccessoryItemFollowHashtag   = @"Accessory Follow Hashtag";
NSString * const VDependencyManagerAccessoryItemMore            = @"Accessory More";
NSString * const VDependencyManagerAccessoryNewMessage          = @"Accessory New Message";
NSString * const VDependencyManagerAccessorySettings            = @"Accessory Menu Settings";
NSString * const VDependencyManagerAccessoryItemLegalInfo       = @"Accessory Legal Information";

static const char kAssociatedObjectSourceViewControllerKey;
static const char kAssociatedObjectBadgeableBarButtonsKey;

@implementation VDependencyManager (VAccessoryScreens)

- (void)addAccessoryScreensToNavigationItem:(UINavigationItem *)navigationItem
                           fromViewController:(UIViewController *)sourceViewController
{
    objc_setAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey, sourceViewController, OBJC_ASSOCIATION_ASSIGN );
    
    NSOrderedSet *accessoryMenuItems = [self accessoriesForSource:sourceViewController];
    
    NSMutableArray *newBarButtonItemsLeft = [[NSMutableArray alloc] init];
    NSMutableArray *newBarButtonItemsRight = [[NSMutableArray alloc] init];
    
    NSMutableArray *badgeableBarButtons = [[NSMutableArray alloc] init];
    
    for ( VNavigationMenuItem *menuItem in accessoryMenuItems )
    {
        if ( ![self shouldDisplayMenuItem:menuItem fromSourceViewController:sourceViewController] )
        {
            continue;
        }
        
        VBarButtonItem *accessoryBarItem = nil;
        
        // See if we have a custom control
        UIControl *customControl = [self customControlForMenuItem:menuItem fromSourceViewController:sourceViewController];
        
        if ( customControl != nil )
        {
            [customControl addTarget:self action:@selector(accessoryMenuItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            VMenuItemControl *menuItemControl = [[VMenuItemControl alloc] initWithFrame:customControl.bounds];
            menuItemControl.menuItem = menuItem;
            [menuItemControl addSubview:customControl];
            
            accessoryBarItem = [[VBarButtonItem alloc] initWithCustomView:menuItemControl];
        }
        else if ( menuItem.icon != nil )
        {
            // If an icon is provided, a badge
            VBarButton *barButton = [VBarButton newWithDependencyManager:self];
            [barButton setImage:menuItem.icon];
            [barButton setTintColor:menuItem.tintColor];
            [barButton addTarget:self action:@selector(accessoryMenuItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            barButton.menuItem = menuItem;
            [badgeableBarButtons addObject:barButton];
            
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
    
    objc_setAssociatedObject( sourceViewController, &kAssociatedObjectBadgeableBarButtonsKey, [badgeableBarButtons copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    
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

- (void)addBadgingToAccessoryScreensInNavigationItem:(UINavigationItem *)navigationItem
                                    fromViewController:(UIViewController *)sourceViewController
{
    NSArray *badgeableBarButtons = objc_getAssociatedObject(sourceViewController, &kAssociatedObjectBadgeableBarButtonsKey);
    for ( VBarButton *barButton in badgeableBarButtons )
    {
        VNavigationMenuItem *menuItem = (VNavigationMenuItem *)barButton.menuItem;
        id<VProvidesNavigationMenuItemBadge> badgeProvider = menuItem.destination;
        id<VProvidesNavigationMenuItemBadge> customBadgeProvider = nil;
        id customBadgeSource = [sourceViewController targetForAction:@selector(customBadgeProviderForMenuItem:) withSender:self];
        customBadgeProvider = [customBadgeSource customBadgeProviderForMenuItem:menuItem];
        [self registerBadgeUpdateBlockWithButton:barButton
                                      fromSource:sourceViewController
                                 withDestination:customBadgeProvider ?: badgeProvider
                                        isCustom:customBadgeProvider != nil];
    }
}

- (void)registerBadgeUpdateBlockWithButton:(VBarButton *)barButton fromSource:(id)source withDestination:(id)destination isCustom:(BOOL)isCustom
{
    if ( [destination conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)] )
    {
        __weak typeof (barButton) weakBarButton = barButton;
        __weak id weakSource = source;
        id<VProvidesNavigationMenuItemBadge> badgeProvider = (id<VProvidesNavigationMenuItemBadge>)destination;
        VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock = ^(NSInteger badgeNumber)
        {
            __strong typeof (weakBarButton) strongBarButton = weakBarButton;
            __strong typeof (weakSource) strongSource = weakSource;
            
            if ( strongBarButton != nil && strongSource != nil )
            {
                [strongBarButton setBadgeNumber:badgeNumber];
                if ( [strongSource conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)] && !isCustom )
                {
                    id<VProvidesNavigationMenuItemBadge> sourceBadgeProvider = (id<VProvidesNavigationMenuItemBadge>)strongSource;
                    if ( sourceBadgeProvider.badgeNumberUpdateBlock != nil )
                    {
                        sourceBadgeProvider.badgeNumberUpdateBlock( badgeNumber );
                    }
                }
            }
        };
        [badgeProvider setBadgeNumberUpdateBlock:badgeNumberUpdateBlock];
        NSInteger badgeNumber = [badgeProvider badgeNumber];
        badgeNumberUpdateBlock( badgeNumber );
    }
}

- (BOOL)shouldDisplayMenuItem:(VNavigationMenuItem *)menuItem fromSourceViewController:(UIViewController *)sourceViewController
{
    if ([AgeGate isAnonymousUser])
    {
        return [AgeGate isAccessoryItemAllowed:menuItem];
    }
    
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

- (UIControl *)customControlForMenuItem:(VNavigationMenuItem *)menuItem fromSourceViewController:(UIViewController *)sourceViewController
{
    // If anyone in the responder chain has a custom control, return the control
    __block UIControl *customControl = nil;
    [sourceViewController v_walkWithBlock:^(UIResponder *responder, BOOL *stop)
     {
         if ( [responder respondsToSelector:@selector(customControlForAccessoryMenuItem:)] )
         {
             id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)responder;
             customControl = [source customControlForAccessoryMenuItem:menuItem];
             *stop = YES;
         }
     }];
    return customControl;
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
    BOOL isNotOnNavigationStack = ![sourceViewController.navigationController.viewControllers containsObject:menuItem.destination];
    
    if ( shouldNavigate && menuItem.hasValidDestination && isValidNavController && isNotOnNavigationStack)
    {
        [sourceViewController.navigationController pushViewController:menuItem.destination animated:YES];
    }
}

@end
