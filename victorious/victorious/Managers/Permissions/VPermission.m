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
        _permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
    }
    return self;
}

- (void)requestPermissionInViewController:(UIViewController *)viewController
                    withCompletionHandler:(VPermissionRequestCompletionHandler)completion
{
    VPermissionState state = [self permissionState];
    if (state == VPermissionStateAuthorized)
    {
        // already have authorization
        if (completion != nil)
        {
            completion(YES, state, nil);
        }
        return;
    }
    
    if (state == VPermissionStateSystemDenied || state == VPermissionUnsupported)
    {
        // were already denied authorization
        if (completion != nil)
        {
            completion(NO, state, nil);
        }
        return;
    }
    
    if (!self.shouldShowInitialPrompt)
    {
        [self requestSystemPermissionWithCompletion:completion];
    }
    else
    {
        // need to request permission for the first time, so we must track it
        VPermissionAlertViewController *permissionAlert = [self.dependencyManager templateValueOfType:[VPermissionAlertViewController class]
                                                                                               forKey:VPermissionAlertViewControllerKey];
        permissionAlert.messageText = [self messageWithDependencyManager:permissionAlert.dependencyManager];
                
        [permissionAlert setConfirmationHandler:^(VPermissionAlertViewController *alert)
         {
             [alert dismissViewControllerAnimated:YES completion:nil];
             [self requestSystemPermissionWithCompletion:completion];
             [self trackPermission:VTrackingValueAuthorized];
         }];
        [permissionAlert setDenyHandler:^(VPermissionAlertViewController *alert)
         {
             [alert dismissViewControllerAnimated:YES completion:^
              {
                  if (completion != nil)
                  {
                      completion(NO, VPermissionStatePromptDenied, nil);
                  }
              }];
             [self trackPermission:VTrackingValueDenied];
         }];
        [viewController presentViewController:permissionAlert animated:YES completion:nil];
    }
}

+ (NSString *)stringFromPermissionState:(VPermissionState)permissionState
{
    switch (permissionState)
    {
        case VPermissionStateAuthorized:
            return VTrackingValueAuthorized;
            break;
        case VPermissionStateSystemDenied:
            return VTrackingValueDenied;
            break;
        default:
            return VTrackingValueUnknown;
            break;
    }
}

#pragma mark - Overrides

- (VPermissionState)permissionState
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
    return VPermissionStateUnknown;
}

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
    return @"";
}

- (void)requestSystemPermissionWithCompletion:(VPermissionRequestCompletionHandler)completion
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

- (void)trackPermission:(NSString *)trackingStatus
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

@end
