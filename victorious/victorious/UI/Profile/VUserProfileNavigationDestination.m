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

@interface VUserProfileNavigationDestination ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VUserProfileNavigationDestination

#pragma mark - Initializers

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
    }
    return self;
}

#pragma mark VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self initWithObjectManager:dependencyManager.objectManager];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - VNavigationDestination conformance

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
        VUserProfileViewController *userProfileViewController = [VUserProfileViewController userProfileWithUser:self.objectManager.mainUser];
        if ( [userProfileViewController respondsToSelector:@selector(setDependencyManager:)] )
        {
            [userProfileViewController setDependencyManager:self.dependencyManager];
        }
        *alternateViewController = userProfileViewController;
        return YES;
    }
    return NO;
}

@end
