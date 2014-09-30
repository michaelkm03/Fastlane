//
//  VAuthorizationViewControllerFactory.m
//  victorious
//
//  Created by Patrick Lynch on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAuthorizationViewControllerFactory.h"
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"
#import "VProfileCreateViewController.h"

@implementation VAuthorizationViewControllerFactory

+ (UIViewController *) requiredViewController
{
    VObjectManager *objectManager = [VObjectManager sharedManager];
    
    if ( objectManager.mainUserLoggedIn && !objectManager.mainUserProfileComplete )
    {
        // User must create (complete) profile
        
        VProfileCreateViewController *viewController = [VProfileCreateViewController profileCreateViewController];
        viewController.profile = [VObjectManager sharedManager].mainUser;
        viewController.registrationModel = [[VRegistrationModel alloc] init];
        return viewController;
    }
    else
    {
        // User must login or create account
        return [VLoginViewController loginViewController];
    }
}

@end
