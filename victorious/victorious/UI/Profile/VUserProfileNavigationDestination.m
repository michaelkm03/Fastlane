//
//  VUserProfileNavigationDestination.m
//  victorious
//
//  Created by Josh Hinman on 11/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAuthorizationViewControllerFactory.h"
#import "VDependencyManager+VObjectManager.h"
#import "VObjectManager.h"
#import "VRootViewController.h"
#import "VUserProfileNavigationDestination.h"
#import "VUserProfileViewController.h"

@implementation VUserProfileNavigationDestination

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [self initWithObjectManager:dependencyManager.objectManager];
}

- (BOOL)shouldNavigateWithAlternateDestination:(UIViewController *__autoreleasing *)alternateViewController
{
    UIViewController *authorizationViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:self.objectManager];
    if (authorizationViewController)
    {
        [[VRootViewController rootViewController] presentViewController:authorizationViewController animated:YES completion:nil];
        return NO;
    }
    else if (alternateViewController != nil)
    {
        *alternateViewController = [VUserProfileViewController userProfileWithUser:self.objectManager.mainUser];
        return YES;
    }
    return NO;
}

@end
