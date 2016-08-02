//
//  VNavigationDestinationWrapperViewController.m
//  victorious
//
//  Created by Michael Sena on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNavigationDestinationContainerViewController.h"

@implementation VNavigationDestinationContainerViewController

#pragma mark - Initializers

- (instancetype)initWithNavigationDestination:(id<VNavigationDestination>)navigationdestination
{
    NSParameterAssert(navigationdestination != nil);
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _navigationDestination = navigationdestination;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSString *)nibBundleOrNil
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark - UIViewController

- (void)loadView
{
    self.view = [[UIView alloc] init];

    if (self.containedViewController != nil)
    {
        [self addChildViewController:self.containedViewController];
        self.containedViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        self.containedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.containedViewController.view];
        [self.containedViewController didMoveToParentViewController:self];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.containedViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.containedViewController;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.containedViewController preferredStatusBarUpdateAnimation];
}

#pragma mark - Property Accessors

- (void)setContainedViewController:(UIViewController *)containedViewController
{
    NSParameterAssert(containedViewController);
    
    if (_containedViewController == containedViewController)
    {
        return;
    }
    
    // Remove previously contained viewController
    [_containedViewController willMoveToParentViewController:nil];
    [_containedViewController.view removeFromSuperview];
    [_containedViewController removeFromParentViewController];
    
    _containedViewController = containedViewController;
    
    // Add new contained viewController
    [self addChildViewController:containedViewController];
    containedViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    containedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    containedViewController.view.frame = self.view.bounds;
    [self.view addSubview:containedViewController.view];
    [containedViewController didMoveToParentViewController:self];
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
