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

@interface VTabMenuShim ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong, readwrite) VBackground *background;
@property (nonatomic, strong) NSArray *badgeProviders;

@end

@implementation VTabMenuShim

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _background = [dependencyManager templateValueOfType:[VBackground class] forKey:@"background"];
    }
    return self;
}

- (NSArray *)wrappedNavigationDesinations
{
    NSMutableArray *wrappedMenuItems = [[NSMutableArray alloc] init];
    NSMutableArray *badgeProviders = [[NSMutableArray alloc] init];
    NSArray *menuItems = [self.dependencyManager menuItems];
    for (VNavigationMenuItem *menuItem in menuItems)
    {
        if ( menuItem.destination == nil )
        {
            continue;
        }
        VNavigationDestinationContainerViewController *shimViewController = [[VNavigationDestinationContainerViewController alloc] initWithNavigationDestination:menuItem.destination];
        VNavigationController *containedNavigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
        
        if ([menuItem.destination isKindOfClass:[UIViewController class]])
        {
            [containedNavigationController.innerNavigationController pushViewController:(UIViewController *)menuItem.destination
                                                                               animated:NO];
            shimViewController.containedViewController = containedNavigationController;
            
            if ([menuItem.destination conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge) ])
            {
                id <VProvidesNavigationMenuItemBadge> badgeProvider = menuItem.destination;
                __weak typeof(self) welf = self;
                [badgeProvider setBadgeNumberUpdateBlock:^(NSInteger badgeNumber)
                {
                    [welf updateApplicationBadge];
                    if (badgeNumber > 0)
                    {
                        shimViewController.tabBarItem.badgeValue = [VBadgeStringFormatter formattedBadgeStringForBadgeNumber:badgeNumber];
                    }
                    else
                    {
                        shimViewController.tabBarItem.badgeValue = nil;
                    }
                }];
                [badgeProviders addObject:badgeProvider];
            }
        }
        
        shimViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                      image:menuItem.icon
                                                              selectedImage:menuItem.selectedIcon];
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
        applicationBadge += [obj badgeNumber];
    }];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:applicationBadge];
}

- (void)willNavigateToIndex:(NSInteger)index
{
    VNavigationMenuItem *menuItem = [[self.dependencyManager menuItems] objectAtIndex:index];
    NSDictionary *params = @{ VTrackingKeyMenuType : VTrackingValueTabBar, VTrackingKeySection : menuItem.title };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMainSection parameters:params];
}

@end
