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
#import "UIResponder+VResponderChain.h"

#import <Objc/runtime.h>

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
    
    NSInteger tag = 0;
    for ( VNavigationMenuItem *menuItem in accessoryMenuItems )
    {
        if ( ![self shouldDisplayMenuItem:menuItem fromSourceViewController:sourceViewController] )
        {
            tag++;
            continue;
        }
        
        UIBarButtonItem *accessoryBarItem = nil;
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
            
            accessoryBarItem = [[UIBarButtonItem alloc] initWithCustomView:barButton];
            accessoryBarItem.tag = barButton.tag = tag++;
        }
        else if ( menuItem.title != nil )
        {
            accessoryBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( menuItem.title, @"" )
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(accessoryMenuItemSelected:)];
            accessoryBarItem.tag = tag++;
        }
        else
        {
            tag++;
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

- (NSInteger)tagForAccessoryBarButton:(UIResponder *)source
{
    UIResponder *responder = source;
    do
    {
        if ( [responder isKindOfClass:[UIBarButtonItem class]] || [responder isKindOfClass:[VBarButton class]] )
        {
            return ((UIBarButtonItem *)responder).tag;
        }
    }
    while (( responder = [responder nextResponder] ));
    return NSNotFound;
}

- (void)accessoryMenuItemSelected:(id)sender
{
    UINavigationController *sourceViewController = objc_getAssociatedObject( self, &kAssociatedObjectSourceViewControllerKey );
    NSOrderedSet *accessoryMenuItems = [self accessoriesForSource:sourceViewController];
    
    NSInteger selectedIndex = [self tagForAccessoryBarButton:sender];
    if ( selectedIndex < 0 || selectedIndex >= (NSInteger)accessoryMenuItems.count )
    {
        return;
    }
    
    VNavigationMenuItem *menuItem = accessoryMenuItems.array[ selectedIndex ];
    UIViewController<VNavigationDestination> *destination = menuItem.destination;
    
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
