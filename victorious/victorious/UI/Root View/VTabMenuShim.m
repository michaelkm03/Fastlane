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

#import "VNavigationController.h"
#import "VNavigationDestinationContainerViewController.h"

@interface VTabMenuShim ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VTabMenuShim

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
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
