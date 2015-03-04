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

@implementation VAuthorization

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
    }
    return self;
}

- (void)performAuthorizedAction:(void(^)())actionBlock failure:(void(^)(UIViewController *authorizationViewController))failureBlock
{
    NSParameterAssert( actionBlock != nil );
    NSParameterAssert( failureBlock != nil );
    NSAssert( self.objectManager != nil, @"Before calling, the `objectManager` property should be set directly or through `initWithObjectManager`." );
    
    if ( self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        VProfileCreateViewController *viewController = [VProfileCreateViewController profileCreateViewController];
        [viewController setAuthorizationCompletionAction:actionBlock];
        viewController.profile = [VObjectManager sharedManager].mainUser;
        viewController.registrationModel = [[VRegistrationModel alloc] init];
        failureBlock( viewController );
    }
    else if ( !self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        VLoginViewController *viewController = [VLoginViewController loginViewController];
        [viewController setAuthorizationCompletionAction:actionBlock];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        failureBlock( navigationController );
    }
    else
    {
        actionBlock();
    }
}

@end
