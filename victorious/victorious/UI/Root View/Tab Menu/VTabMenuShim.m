//
//  VTabMenuShim.m
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTabMenuShim.h"

// Dependency Manager + Helpers
#import "VDependencyManager+VNavigationMenuItem.h"

// Navigation
#import "VNavigationMenuItem.h"
#import "VNavigationDestination.h"

// UI
#import "VNavigationController.h"
#import "VNavigationDestinationContainerViewController.h"
#import "VBackground.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "VBadgeStringFormatter.h"
#import "UIImage+ImageCreation.h"

#import "VWorkspaceShimDestination.h"
#import "victorious-Swift.h"

@interface VTabMenuShim ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong, readwrite) VBackground *background;
@property (nonatomic, strong) NSArray *badgeProviders;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, retain) UIColor *unselectedIconColor;

@end

@implementation VTabMenuShim

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _background = [dependencyManager templateValueOfType:[VBackground class] forKey:@"background"];
        _selectedIconColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        _unselectedIconColor = [dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey];
        _menuItems = [dependencyManager menuItems];
        
        // Filter menu items for age gate if necessary
        if ( [AgeGate isAnonymousUser] )
        {
            _menuItems = [AgeGate filterTabMenuItems:_menuItems];
        }
    }
    return self;
}

- (NSArray *)wrappedNavigationDesinations
{
    NSMutableArray *wrappedMenuItems = [[NSMutableArray alloc] init];
    NSMutableArray *badgeProviders = [[NSMutableArray alloc] init];
    for (VNavigationMenuItem *menuItem in self.menuItems)
    {
        if ( menuItem.destination == nil )
        {
            continue;
        }
        
        VNavigationDestinationContainerViewController *shimViewController = [[VNavigationDestinationContainerViewController alloc] initWithNavigationDestination:menuItem.destination];
        
        if ([menuItem.destination isKindOfClass:[UIViewController class]])
        {
            UIViewController *viewController = (UIViewController *)menuItem.destination;
            VNavigationController *containedNavigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
            [containedNavigationController.innerNavigationController pushViewController:viewController animated:NO];
            shimViewController.containedViewController = containedNavigationController;
        }
        
        if ([menuItem.destination conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge) ])
        {
            id <VProvidesNavigationMenuItemBadge> badgeProvider = menuItem.destination;
            __weak typeof(self) welf = self;
            __weak VNavigationDestinationContainerViewController *weakShim = shimViewController;
            badgeProvider.badgeNumberUpdateBlock = ^(NSInteger badgeNumber)
            {
                [welf updateApplicationBadge];
                if (badgeNumber > 0)
                {
                    weakShim.tabBarItem.badgeValue = [VBadgeStringFormatter formattedBadgeStringForBadgeNumber:badgeNumber];
                }
                else
                {
                    weakShim.tabBarItem.badgeValue = nil;
                }
            };
            [badgeProviders addObject:badgeProvider];
        }
        
        UIImage *image = [[menuItem.icon v_imageByMaskingImageWithColor:self.unselectedIconColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        shimViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle: menuItem.identifier ?: @"Menu Create" image:image selectedImage:menuItem.selectedIcon];
        [shimViewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]} forState:UIControlStateNormal];
        shimViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        [wrappedMenuItems addObject:shimViewController];
    }
    self.badgeProviders = [NSArray arrayWithArray:badgeProviders];
    return wrappedMenuItems;
}

- (void)updateApplicationBadge
{
    __block NSInteger applicationBadge = 0;
    [self.badgeProviders enumerateObjectsUsingBlock:^(id <VProvidesNavigationMenuItemBadge> obj, NSUInteger idx, BOOL *stop)
    {
        applicationBadge += [obj respondsToSelector:@selector(badgeNumber)] ? [obj badgeNumber] : 0;
    }];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:applicationBadge];
}

- (void)willNavigateToIndex:(NSInteger)index
{
    // Track selection of main menu item
    VNavigationMenuItem *menuItem = self.menuItems[index];
    NSDictionary *params = @{ VTrackingKeyMenuType : VTrackingValueTabBar, VTrackingKeySection : menuItem.title ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMainSection parameters:params];
    
    // Track any additional events unique to this menu item
    // Hacky until proper template-based tracking can solve the problem of tracking event `UserDidSelectCreatePost`
    if ( [menuItem.destination isKindOfClass:[VWorkspaceShimDestination class]] )
    {
        NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueTabBar };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreatePost parameters:params];
    }
}

@end
