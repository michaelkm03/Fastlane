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
    
    NSLog( @"accessoryMenuItems = %@", accessoryMenuItems );
    
    NSMutableArray *barButtonItemsLeft = [[NSMutableArray alloc] init];
    NSMutableArray *barButtonItemsRight = [[NSMutableArray alloc] init];
    
    NSInteger tag = 0;
    for ( VNavigationMenuItem *menuItem in accessoryMenuItems )
    {
        /**/
        
        id<VAccessoryNavigationSource> source;
        id responder = sourceViewController;
        BOOL shouldDisplay = YES;
        do
        {
            if ( [responder respondsToSelector:@selector(shouldDisplayAccessoryMenuItem:fromSource:)] )
            {
                source = (id<VAccessoryNavigationSource>)responder;
                
                // If anyone in the responder chain can and does say no, then we don't display
                if ( ![source shouldDisplayAccessoryMenuItem:menuItem fromSource:sourceViewController] )
                {
                    shouldDisplay = NO;
                    break;
                }
            }
        }
        while (( responder = [responder nextResponder] ));
        
        if ( !shouldDisplay )
        {
            tag++;
            continue;
        }
        
        UIBarButtonItem *accessoryBarItem = nil;
        if ( menuItem.icon != nil )
        {
            // If an icon is provided, a badge
            NSDictionary *configuration = @{ VHamburgerButtonIconKey : menuItem.icon };
            VBarButton *barButton = [VBarButton newWithDependencyManager:[self childDependencyManagerWithAddedConfiguration:configuration]];
            [barButton addTarget:self action:@selector(accessoryMenuItemSelected:)
                forControlEvents:UIControlEventTouchUpInside];
            
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
            [barButtonItemsRight addObject:accessoryBarItem];
        }
        else if ( ([menuItem.position isEqualToString:VDependencyManagerPositionLeft] || menuItem.position == nil) )
        {
            [barButtonItemsLeft addObject:accessoryBarItem];
        }
    }
    
    navigationItem.leftBarButtonItems = barButtonItemsLeft;
    navigationItem.rightBarButtonItems = barButtonItemsRight;
}

- (NSOrderedSet *)accessoriesForSource:(UIResponder *)source
{
    return [[NSOrderedSet alloc] initWithArray:self.accessoryMenuItems];
    
    // Walk the responder chain and collect accessoryMenuItems from each responders dependencyManager
    NSMutableOrderedSet *accessoryMenuItems = [[NSMutableOrderedSet alloc] init];
    UIResponder *responder = source;
    do
    {
        id<VHasManagedDependencies> dependenyOwner = (id<VHasManagedDependencies>)responder;
        if ( [dependenyOwner respondsToSelector:@selector(dependencyManager)] )
        {
            [accessoryMenuItems addObjectsFromArray:[dependenyOwner dependencyManager].accessoryMenuItems];
        }
    }
    while (( responder = [responder nextResponder] ));
    
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
    
    id <VAuthorizationContextProvider> authorizedDestination = (id <VAuthorizationContextProvider>)destination;
    BOOL requiresAuthorization = [authorizedDestination conformsToProtocol:@protocol(VAuthorizationContextProvider)] &&
    authorizedDestination.requiresAuthorization;
    
    if ( requiresAuthorization )
    {
        VAuthorizationContext context = [authorizedDestination authorizationContext];
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

- (void)performNavigationFromSource:(UIViewController *)sourceViewController
                       withMenuItem:(VNavigationMenuItem *)menuItem
{
    BOOL shouldNavigate = YES;
    UIResponder *responder = sourceViewController;
    do
    {
        id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)[responder targetForAction:@selector(shouldNavigateWithAccessoryMenuItem:) withSender:self];
        if ( source != nil && ![source shouldNavigateWithAccessoryMenuItem:menuItem] )
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
