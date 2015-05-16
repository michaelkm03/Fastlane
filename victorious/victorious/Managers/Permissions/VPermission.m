//
//  VPermission.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermission.h"

@implementation VPermission

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)requestPermissionIfNecessaryInViewController:(UIViewController *)viewController
                               withCompletionHandler:(VPermissionRequestCompletionHandler)completion
{
    VPermissionState state = [self permissionState];
    if (state == VPermissionStateAuthorized)
    {
        if (completion)
        {
            completion(YES, state, nil);
        }
        return;
    }
    
    if (state == VPermissionStateSystemDenied || state == VPermissionUnsupported)
    {
        if (completion)
        {
            completion(NO, state, nil);
        }
        return;
    }
    
    _presentingViewController = viewController;
    [self requestForPermission:completion];
}

#pragma mark - Overrides

- (VPermissionState)permissionState
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
    return VPermissionStateUnknown;
}

- (void)requestForPermission:(VPermissionRequestCompletionHandler)completion
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

@end
