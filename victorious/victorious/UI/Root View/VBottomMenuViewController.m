//
//  VBottomMenuViewController.m
//  victorious
//
//  Created by Michael Sena on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBottomMenuViewController.h"

// UIModels
#import "VNavigationMenuItem.h"

// DependencyManager Helpers
#import "VDependencyManager+VNavigationMenuItem.h"

// ViewControllers
#import "VNavigationController.h"

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
    [self addChildViewController:self.internalTabBarViewController];
    self.internalTabBarViewController.view.frame = self.view.bounds;
    self.internalTabBarViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.internalTabBarViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;;
    [self.view addSubview:self.internalTabBarViewController.view];
    [self.internalTabBarViewController didMoveToParentViewController:self];
    
    self.internalTabBarViewController.viewControllers = [self wrappedNavigationDesinations];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}

#pragma mark - Private Methods

- (NSArray *)wrappedNavigationDesinations
{
    NSMutableArray *wrappedMenuItems = [[NSMutableArray alloc] init];
    NSArray *menuItems = [self.dependencyManager menuItems];
    for (VNavigationMenuItem *menuItem in menuItems)
    {
        VNavigationController *navigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
        [navigationController.innerNavigationController pushViewController:menuItem.destination animated:NO];
        [wrappedMenuItems addObject:navigationController];
    }
    return wrappedMenuItems;
}

@end
