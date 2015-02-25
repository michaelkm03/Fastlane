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

// Backgrounds
#import "VSolidColorBackground.h"


@interface VBottomMenuViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong, readwrite) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UITabBarController *internalTabBarViewController;

@property (nonatomic, strong) VNavigationDestinationContainerViewController *willSelectContainerViewController;

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
    
    // Configure Tab Bar
    [self.internalTabBarViewController.tabBar setTintColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]];
    VBackground *backgroundForTabBar = [self.dependencyManager templateValueOfType:[VBackground class] forKey:VDependencyManagerBackgroundKey];
    if ([backgroundForTabBar isKindOfClass:[VSolidColorBackground class]])
    {
        VSolidColorBackground *solidColorBackground = (VSolidColorBackground *)backgroundForTabBar;
        self.internalTabBarViewController.tabBar.translucent = NO;
        self.internalTabBarViewController.tabBar.barTintColor = solidColorBackground.backgroundColor;
    }
    
    [self.view addSubview:self.internalTabBarViewController.view];
    [self.internalTabBarViewController didMoveToParentViewController:self];
    
    self.internalTabBarViewController.viewControllers = [self wrappedNavigationDesinations];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.internalTabBarViewController.selectedViewController != nil)
    {
        [self.internalTabBarViewController.selectedViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(VNavigationDestinationContainerViewController *)viewController
{
    self.willSelectContainerViewController = viewController;
    [self navigateToDestination:viewController.navigationDestination];
    return NO;
}

- (void)displayResultOfNavigation:(UIViewController *)viewController
{
    if ( self.presentedViewController != nil )
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    if (self.willSelectContainerViewController != nil)
    {
        if (self.willSelectContainerViewController.containedViewController == nil)
        {
            VNavigationController *navigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
            [navigationController.innerNavigationController pushViewController:viewController
                                                                      animated:NO];
            [self.willSelectContainerViewController setContainedViewController:navigationController];
        }
        [self.internalTabBarViewController setSelectedViewController:self.willSelectContainerViewController];
        self.willSelectContainerViewController = nil;
        return;
    }
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
        
        shimViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                      image:menuItem.icon
                                                              selectedImage:menuItem.icon];
        shimViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        [wrappedMenuItems addObject:shimViewController];
    }
    return wrappedMenuItems;
}

@end
