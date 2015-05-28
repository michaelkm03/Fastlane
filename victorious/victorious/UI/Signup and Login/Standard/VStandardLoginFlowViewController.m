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

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VStandardLoginFlowViewController *standardLoginFLowController = [[VStandardLoginFlowViewController alloc] initWithNibName:nil bundle:nil];
    standardLoginFLowController.dependencyManager = dependencyManager;
    standardLoginFLowController.vTransitioninDelegate = [[VTransitionDelegate alloc] initWithTransition:[[VPresentWithBlurTransition alloc] init]];
    [standardLoginFLowController setTransitioningDelegate:standardLoginFLowController.vTransitioninDelegate];
    return standardLoginFLowController;
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
