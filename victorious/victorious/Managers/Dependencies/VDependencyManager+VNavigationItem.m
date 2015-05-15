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

@interface VDependencyManager()

@property (nonatomic, strong) VDependencyManager *parentManager;

@end

@implementation VDependencyManager (VNavigationItem)

- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem
{
    [self addPropertiesToNavigationItem:navigationItem source:nil];
}

- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem
                               source:(UIViewController *)sourceViewController
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
    
    if ( self.accessoryMenuItems.count > 0 )
    {
        objc_setAssociatedObject(self, &kAssociatedObjectKey, sourceViewController, OBJC_ASSOCIATION_ASSIGN);
        
        NSMutableArray *barButtonItemsLeft = [[NSMutableArray alloc] init];
        NSMutableArray *barButtonItemsRight = [[NSMutableArray alloc] init];
        
        VDependencyManager *dependencyManager = self;
        NSMutableArray *accessoryMenuItems = [[NSMutableArray alloc] initWithArray:dependencyManager.accessoryMenuItems];
        while ( dependencyManager.parentManager != nil )
        {
            dependencyManager = dependencyManager.parentManager;
            [accessoryMenuItems addObjectsFromArray:dependencyManager.accessoryMenuItems];
        }
        
        for ( VNavigationMenuItem *menuItem in self.accessoryMenuItems )
        {
            id<VAccessoryNavigationSource> source;
            id responder = sourceViewController;
            BOOL shouldDisplay = YES;
            while (( responder = [responder nextResponder] ))
            {
                if ( [responder respondsToSelector:@selector(shouldDisplayAccessoryForDestination:)] )
                {
                    source = (id<VAccessoryNavigationSource>)responder;
                    
                    // If anyone in the responder chain says no, then we don't display
                    if ( ![source shouldDisplayAccessoryForDestination:menuItem.destination] )
                    {
                        shouldDisplay = NO;
                        break;
                    }
                }
            }
            
            if ( !shouldDisplay )
            {
                continue;
            }
            
            /*NSString *tab = @"";
            UIResponder *responder = sourceViewController;
            while (( responder = [responder nextResponder] ))
            {
                tab = [tab stringByAppendingString:@"\t"];
                NSInteger index = [[responder description] rangeOfString:@":"].location;
                NSLog( @"\n%@- %@\n", tab, [[responder description] substringToIndex:index] );
            }*/
            
            // Check if the source can display the menu item (default is YES)
            /*id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)[sourceViewController targetForAction:@selector(shouldDisplayAccessoryForDestination:) withSender:self];
            if ( [source conformsToProtocol:@protocol(VAccessoryNavigationSource)] )
            {
                if ( ![source shouldDisplayAccessoryForDestination:menuItem.destination] )
                {
                    continue;
                }
            }*/
            
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
    UINavigationController *sourceViewController = objc_getAssociatedObject(self, &kAssociatedObjectKey);
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
                 [self performNavigationFromSource:sourceViewController toDestination:destination];
             }
         }];
    }
    else if ( canNavigationToDestination )
    {
        [self performNavigationFromSource:sourceViewController toDestination:destination];
    }
}

- (void)performNavigationFromSource:(UIViewController *)sourceViewController
                       toDestination:(UIViewController *)destination
{
    id<VAccessoryNavigationSource> source = (id<VAccessoryNavigationSource>)[sourceViewController targetForAction:@selector(willNavigationToDestination:) withSender:self];
    
    BOOL shouldNavigate = sourceViewController.navigationController != nil;
    if ( [source respondsToSelector:@selector(willNavigationToDestination:)] )
    {
        shouldNavigate = [source willNavigationToDestination:destination];
    }
    if ( shouldNavigate && destination != nil && ![destination isKindOfClass:[NSNull class]] )
    {
        [sourceViewController.navigationController pushViewController:destination animated:YES];
    }
}

@end
