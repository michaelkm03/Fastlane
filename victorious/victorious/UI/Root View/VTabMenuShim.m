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
    NSArray *menuItems = [self.dependencyManager menuItems];
    for (VNavigationMenuItem *menuItem in menuItems)
    {
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
                [badgeProvider setBadgeNumberUpdateBlock:^(NSInteger badgeNumber)
                {
                    shimViewController.tabBarItem.badgeValue = [VBadgeStringFormatter formattedBadgeStringForBadgeNumber:badgeNumber];
                    if ([shimViewController.tabBarItem.badgeValue isEqualToString:@""])
                    {
                        shimViewController.tabBarItem.badgeValue = nil;
                    }
                }];
            }
        }
        
        shimViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                      image:menuItem.icon
                                                              selectedImage:menuItem.selectedIcon];
        shimViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        [wrappedMenuItems addObject:shimViewController];
    }
    return wrappedMenuItems;
}

@end
