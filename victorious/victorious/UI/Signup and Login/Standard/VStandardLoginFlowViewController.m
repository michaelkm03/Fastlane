//
//  VStandardLoginFlowViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStandardLoginFlowViewController.h"
#import "VPresentWithBlurTransition.h"
#import "VTransitionDelegate.h"
#import "VLoginViewController.h"

@class VObjectManager, VDependencyManager;

@interface VStandardLoginFlowViewController ()

@property (nonatomic, strong) VTransitionDelegate *vTransitioninDelegate;
@property (nonatomic, assign) VAuthorizationContext authorizationContext;
@property (nonatomic, strong) VLoginFlowCompletionBlock completionBlock;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VStandardLoginFlowViewController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    NSAssert(false, @"This navigation controller manages its own nav stack.");
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _vTransitioninDelegate = [[VTransitionDelegate alloc] initWithTransition:[[VPresentWithBlurTransition alloc] init]];
    [self setTransitioningDelegate:_vTransitioninDelegate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    VLoginViewController *loginViewController = [VLoginViewController newWithDependencyManager:self.dependencyManager];
    loginViewController.authorizedAction = self.completionBlock;
    loginViewController.authorizationContextType = self.authorizationContext;
    self.viewControllers = @[loginViewController];
}

@end
