//
//  VAuthorizedAction.m
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAuthorizedAction.h"
#import "VObjectManager+Login.h"
#import "VProfileCreateViewController.h"
#import "VDependencyManager.h"
#import "VStandardLoginFlowViewController.h"

@interface VAuthorizedAction()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) VObjectManager *objectManager;

@end

@implementation VAuthorizedAction

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
                    dependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert( dependencyManager != nil );
    NSParameterAssert( objectManager != nil );
    
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (BOOL)performFromViewController:(UIViewController *)presentingViewController
                          context:(VAuthorizationContext)authorizationContext
                       completion:(void(^)(BOOL authorized))completionActionBlock
{
    NSParameterAssert( completionActionBlock != nil );
    NSParameterAssert( presentingViewController != nil );
    
    NSAssert( self.objectManager != nil, @"Before calling, the `objectManager` property should be set directly or through `initWithObjectManager`." );
    
    if ( self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        VProfileCreateViewController *viewController = [VProfileCreateViewController newWithDependencyManager:self.dependencyManager];
        [viewController setAuthorizedAction:completionActionBlock];
        viewController.profile = [VObjectManager sharedManager].mainUser;
        viewController.registrationModel = [[VRegistrationModel alloc] init];
        [presentingViewController presentViewController:viewController animated:YES completion:nil];
        return NO;
    }
    else if ( !self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        VStandardLoginFlowViewController *loginFlowController = [[VStandardLoginFlowViewController alloc] initWithAuthorizationContext:authorizationContext
                                                                                                                         ObjectManager:self.objectManager
                                                                                                                     dependencyManager:self.dependencyManager
                                                                                                                            completion:completionActionBlock];

        [presentingViewController presentViewController:loginFlowController
                                               animated:YES
                                             completion:nil];
        return NO;
    }
    else
    {
        completionActionBlock(YES);
        return YES;
    }
}

@end
