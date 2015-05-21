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
#import "UIResponder+VResponderChain.h"

#import <Objc/runtime.h>


@interface VBarButtonItem : UIBarButtonItem

@property (nonatomic, copy) NSString *menuItemIdentifier;

@end

@implementation VBarButtonItem

@end


#define LOG_ACTIVITY 0
#if LOG_ACTIVITY
#warning VDependencyManager+VNavigationItem loggin is enabled!! Turn it off before merging.
#endif

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
    NSOrderedSet *accessoryMenuItems = [self accessoriesForSource:sourceViewController];
    
#if LOG_ACTIVITY
    VLog( @">>>> accessoryMenuItems = %@", accessoryMenuItems );
#endif
    
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
            
            id<VNavigationDestination> destination = (id<VNavigationDestination>)menuItem.destination;
            if ( [destination respondsToSelector:@selector(badgeNumber)] )
            {
                barButton.badgeNumber = [destination badgeNumber];
            }
            
            accessoryBarItem = [[VBarButtonItem alloc] initWithCustomView:barButton];
            barButton.menuItemIdentifier = menuItem.identifier;
            accessoryBarItem.menuItemIdentifier = menuItem.identifier;
        }
        else if ( menuItem.title != nil )
        {
            accessoryBarItem = [[VBarButtonItem alloc] initWithTitle:NSLocalizedString( menuItem.title, @"" )
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                              action:@selector(accessoryMenuItemSelected:)];
            accessoryBarItem.menuItemIdentifier = menuItem.identifier;
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
    
    {
        NSArray *existingItems = navigationItem.leftBarButtonItems;
        BOOL animated = existingItems.count != newBarButtonItemsLeft.count;
        [navigationItem setLeftBarButtonItems:newBarButtonItemsLeft animated:animated];
    }{
        NSArray *existingItems = navigationItem.rightBarButtonItems;
        BOOL animated = existingItems.count != newBarButtonItemsRight.count;
        [navigationItem setRightBarButtonItems:newBarButtonItemsRight animated:animated];
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
    // Walk the responder chain and collect accessoryMenuItems from each responders dependencyManager
    __block NSMutableOrderedSet *accessoryMenuItems = [[NSMutableOrderedSet alloc] init];
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
            return ((VBarButton *)responder).menuItemIdentifier;
        }
        else if ( [responder isKindOfClass:[VBarButtonItem class]] )
        {
            return ((VBarButtonItem *)responder).menuItemIdentifier;
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
    for ( VBarButtonItem *item in navigationItme.leftBarButtonItems )
    {
        if ( [item isKindOfClass:[VBarButtonItem class]] )
        {
            return item;
        }
    }
    for ( VBarButtonItem *item in navigationItme.rightBarButtonItems )
    {
        if ( [item isKindOfClass:[VBarButtonItem class]] )
        {
            return item;
        }
    }
    return nil;
}

- (VNavigationMenuItem *)menuItemWithIdentifier:(NSString *)identifier
{
    UINavigationController *sourceViewController = objc_getAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey );
    NSOrderedSet *accessoryMenuItems = [self accessoriesForSource:sourceViewController];
    
    for ( VNavigationMenuItem *menuITem in accessoryMenuItems )
    {
        if ( [menuITem.identifier isEqualToString:identifier] )
        {
            return menuITem;
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
#if LOG_ACTIVITY
    VLog( @">>>> performNavigationFromSource = %@", sourceViewController );
#endif
    
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
