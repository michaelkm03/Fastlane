//
//  VBottomMenuViewController.m
//  victorious
//
//  Created by Michael Sena on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBottomMenuViewController.h"

// UI Models
#import "VNavigationMenuItem.h"
#import "VNavigationDestination.h"

// DependencyManager Helpers
#import "VDependencyManager+VNavigationMenuItem.h"

// ViewControllers
#import "VNavigationController.h"
#import "VNavigationDestinationContainerViewController.h"

@interface VBottomMenuViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong, readwrite) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UITabBarController *internalTabBarViewController;

@end

@implementation VBottomMenuViewController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    self.view = view;
    
    self.internalTabBarViewController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    self.internalTabBarViewController.delegate = self;
    [self addChildViewController:self.internalTabBarViewController];
    self.internalTabBarViewController.view.frame = self.view.bounds;
    self.internalTabBarViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.internalTabBarViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.internalTabBarViewController.tabBar setBarTintColor:[self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey]];
    [self.internalTabBarViewController.tabBar setTintColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]];
    
    [self.view addSubview:self.internalTabBarViewController.view];
    [self.internalTabBarViewController didMoveToParentViewController:self];
    
    self.internalTabBarViewController.viewControllers = [self wrappedNavigationDesinations];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(VNavigationDestinationContainerViewController *)viewController
{
    if ([viewController.navigationDestination respondsToSelector:@selector(shouldNavigateWithAlternateDestination:)])
    {
        UIViewController *alternateDestinationViewController = nil;
        if (![viewController.navigationDestination shouldNavigateWithAlternateDestination:&alternateDestinationViewController])
        {
            return NO;
        }
        else
        {
            if (viewController.containedViewController == nil)
            {
                VNavigationController *navigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
                [navigationController.innerNavigationController pushViewController:alternateDestinationViewController
                                                                          animated:NO];
                viewController.containedViewController = navigationController;
            }
            return YES;
        }
    }
    
    return YES;
}

#pragma mark - Private Methods

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
        
        shimViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:menuItem.title image:nil selectedImage:nil];
        [wrappedMenuItems addObject:shimViewController];
    }
    return wrappedMenuItems;
}

@end
