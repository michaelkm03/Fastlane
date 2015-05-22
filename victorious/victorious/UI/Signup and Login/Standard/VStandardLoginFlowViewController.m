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

@interface VStandardLoginFlowViewController ()

@property (nonatomic, strong) VTransitionDelegate *vTransitioninDelegate;

@end

@implementation VStandardLoginFlowViewController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    NSAssert(false, @"Must use: initWithAuthorizationContext:objectManager:dependencyManager:");
    return nil;
}

- (instancetype)init
{
    NSAssert(false, @"Must use: initWithAuthorizationContext:objectManager:dependencyManager:");
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(false, @"Must use: initWithAuthorizationContext:objectManager:dependencyManager:");
    return nil;
}

- (instancetype)initWithAuthorizationContext:(VAuthorizationContext)authorizationContext
                               ObjectManager:(VObjectManager *)objectManager
                           dependencyManager:(VDependencyManager *)dependencyManager
                                  completion:(void(^)(BOOL authorized))completionActionBlock
{
    VLoginViewController *loginViewController = [VLoginViewController newWithDependencyManager:dependencyManager];
    loginViewController.authorizedAction = completionActionBlock;
    loginViewController.authorizationContextType = authorizationContext;
    self = [super initWithRootViewController:loginViewController];
    if (self)
    {
        _vTransitioninDelegate = [[VTransitionDelegate alloc] initWithTransition:[[VPresentWithBlurTransition alloc] init]];
        [self setTransitioningDelegate:_vTransitioninDelegate];
    }
    return self;
}

@end
