//
//  VPermissionPhotoLibrary.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionPhotoLibrary.h"

@import AssetsLibrary;

@implementation VPermissionPhotoLibrary

- (VPermissionState)permissionState
{
    ALAuthorizationStatus systemState = [ALAssetsLibrary authorizationStatus];
    switch (systemState)
    {
        case ALAuthorizationStatusAuthorized:
            return VPermissionStateAuthorized;
        case ALAuthorizationStatusDenied:
        case ALAuthorizationStatusRestricted:
            return VPermissionStateSystemDenied;
        case ALAuthorizationStatusNotDetermined:
            return VPermissionStateUnknown;
    }
}

- (void)requestForPermission:(VPermissionRequestCompletionHandler)completion
{
    VPermissionAlertViewController *permissionAlert = [self.dependencyManager templateValueOfType:[VPermissionAlertViewController class]
                                                                                           forKey:VPermissionAlertViewControllerKey];
    [permissionAlert setConfirmationHandler:^(VPermissionAlertViewController *alert)
    {
        [alert dismissViewControllerAnimated:YES completion:^
        {
            ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
            {
                if (group == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        completion(YES, [self permissionState], nil);
                    });
                }
            } failureBlock:^(NSError *error)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(NO, [self permissionState], nil);
                });
            }];
        }];
    }];
    [permissionAlert setDenyHandler:^(VPermissionAlertViewController *alert)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [alert dismissViewControllerAnimated:YES completion:^
            {
                if (completion)
                {
                    completion(NO, VPermissionStatePromptDenied, nil);
                }
            }];
        });
    }];
    [self.presentingViewController presentViewController:permissionAlert animated:YES completion:nil];
}

@end
