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

#pragma mark - UIViewController view lifecycle

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
    }
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
    [self.view addSubview:containedViewController.view];
    [containedViewController didMoveToParentViewController:self];
}

@end
