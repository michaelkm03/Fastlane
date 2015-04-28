//
//  VBottomMenuViewController.m
//  victorious
//
//  Created by Michael Sena on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTabMenuViewController.h"

// UI Models
#import "VNavigationMenuItem.h"
#import "VNavigationDestination.h"

// DependencyManager Helpers
#import "VTabMenuShim.h"

// ViewControllers
#import "VNavigationController.h"
#import "VNavigationDestinationContainerViewController.h"

// Backgrounds
#import "VSolidColorBackground.h"

// Categories
#import "NSArray+VMap.h"

NSString * const kMenuKey = @"menu";

@interface VTabMenuViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UITabBarController *internalTabBarViewController;
@property (nonatomic, strong) VNavigationDestinationContainerViewController *willSelectContainerViewController;
@property (nonatomic, strong) VTabMenuShim *tabShim;

@end

@implementation VTabMenuViewController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _tabShim = [dependencyManager templateValueOfType:[VTabMenuShim class] forKey:kMenuKey];
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
    [self.internalTabBarViewController.tabBar setTintColor:self.tabShim.selectedIconColor];
    VBackground *backgroundForTabBar = self.tabShim.background;
    if ([backgroundForTabBar isKindOfClass:[VSolidColorBackground class]])
    {
        VSolidColorBackground *solidColorBackground = (VSolidColorBackground *)backgroundForTabBar;
        self.internalTabBarViewController.tabBar.translucent = NO;
        self.internalTabBarViewController.tabBar.barTintColor = solidColorBackground.backgroundColor;
    }
    
    [self.view addSubview:self.internalTabBarViewController.view];
    [self.internalTabBarViewController didMoveToParentViewController:self];
    
    self.internalTabBarViewController.viewControllers = [self.tabShim wrappedNavigationDesinations];
    
    UIViewController *initialVC = [self.dependencyManager singletonViewControllerForKey:VDependencyManagerInitialViewControllerKey];
    if (initialVC != nil)
    {
        [self displayResultOfNavigation:initialVC];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.internalTabBarViewController.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.internalTabBarViewController.selectedViewController;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.tabBarController.selectedViewController preferredStatusBarUpdateAnimation];
}

#pragma mark - VScaffoldViewController

- (NSArray *)navigationDestinations
{
    return [self.internalTabBarViewController.viewControllers v_map:^id(VNavigationDestinationContainerViewController *container)
    {
        if ( [container isKindOfClass:[VNavigationDestinationContainerViewController class]] )
        {
            return container.navigationDestination;
        }
        else
        {
            return container;
        }
    }];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(VNavigationDestinationContainerViewController *)viewController
{
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if ( index != NSNotFound )
    {
        [self.tabShim willNavigateToIndex:index];
    }
    
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
    
    if ( self.willSelectContainerViewController == nil )
    {
        for ( VNavigationDestinationContainerViewController *containerViewController in self.internalTabBarViewController.viewControllers )
        {
            if ( [containerViewController isKindOfClass:[VNavigationDestinationContainerViewController class]] &&
                 (id)containerViewController.navigationDestination == viewController)
            {
                self.willSelectContainerViewController = containerViewController;
                break;
            }
        }
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
        [self setNeedsStatusBarAppearanceUpdate];
        self.willSelectContainerViewController = nil;
    }
    else if ( [self.internalTabBarViewController.selectedViewController isKindOfClass:[VNavigationDestinationContainerViewController class]] )
    {
        VNavigationDestinationContainerViewController *containerViewController = (VNavigationDestinationContainerViewController *)self.internalTabBarViewController.selectedViewController;
        if ( [containerViewController.containedViewController isKindOfClass:[VNavigationController class]] )
        {
            VNavigationController *navigationController = (VNavigationController *)containerViewController.containedViewController;
            [navigationController.innerNavigationController pushViewController:viewController animated:YES];
        }
    }
}

@end
