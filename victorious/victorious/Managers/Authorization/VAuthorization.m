//
//  VAuthorization.m
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAuthorization.h"
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"
#import "VProfileCreateViewController.h"
#import "VPresentWithBlurTransition.h"
#import "VTransitionDelegate.h"
#import "VDependencyManager.h"

@interface VAuthorization()

@property (nonatomic, strong) VTransitionDelegate *transition;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VAuthorization

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
                    dependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _dependencyManager = dependencyManager;
        _transition = [[VTransitionDelegate alloc] initWithTransition:[[VPresentWithBlurTransition alloc] init]];
    }
    return self;
}

- (BOOL)performAuthorizedActionFromViewController:(UIViewController *)presentingViewController
                                      withContext:(VLoginContextType)loginContext
                                      withSuccess:(void(^)())successActionBlock
{
    NSParameterAssert( successActionBlock != nil );
    NSParameterAssert( presentingViewController != nil );
    
    NSAssert( self.objectManager != nil, @"Before calling, the `objectManager` property should be set directly or through `initWithObjectManager`." );
    
    if ( self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        VProfileCreateViewController *viewController = [VProfileCreateViewController profileCreateViewController];
        [viewController setAuthorizationCompletionAction:successActionBlock];
        viewController.profile = [VObjectManager sharedManager].mainUser;
        viewController.registrationModel = [[VRegistrationModel alloc] init];
        [presentingViewController presentViewController:viewController animated:YES completion:nil];
        return NO;
    }
    else if ( !self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        VLoginViewController *viewController = [VLoginViewController loginViewController];
        viewController.loginContextType = loginContext;
        [viewController setAuthorizationCompletionAction:successActionBlock];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        viewController.transitionDelegate = self.transition;
        [presentingViewController presentViewController:navigationController animated:YES completion:nil];
        return NO;
    }
    else
    {
        successActionBlock();
        return YES;
    }
}

@end
