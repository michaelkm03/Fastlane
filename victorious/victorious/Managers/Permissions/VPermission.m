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
        _shouldShowInitialPrompt = YES;
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
    
    if (self.shouldShowInitialPrompt == NO)
    {
        [self requestForPermission:completion];
    }
    else
    {
        VPermissionAlertViewController *permissionAlert = [self.dependencyManager templateValueOfType:[VPermissionAlertViewController class]
                                                                                               forKey:VPermissionAlertViewControllerKey];
        permissionAlert.messageText = [self messageWithDependencyManager:permissionAlert.dependencyManager];
                
        [permissionAlert setConfirmationHandler:^(VPermissionAlertViewController *alert)
         {
             [alert dismissViewControllerAnimated:YES completion:nil];
             [self requestForPermission:completion];
         }];
        [permissionAlert setDenyHandler:^(VPermissionAlertViewController *alert)
         {
             [alert dismissViewControllerAnimated:YES completion:^
              {
                  if (completion)
                  {
                      completion(NO, VPermissionStatePromptDenied, nil);
                  }
              }];
         }];
        [viewController presentViewController:permissionAlert animated:YES completion:nil];
    }
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

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
    return @"";
}

@end
