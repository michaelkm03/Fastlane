//
//  VPermissionCamera.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionCamera.h"

@import AVFoundation;

@implementation VPermissionCamera

- (VPermissionState)permissionState
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus)
    {
        case AVAuthorizationStatusAuthorized:
            return VPermissionStateAuthorized;
            
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            return VPermissionStateSystemDenied;
            
        case AVAuthorizationStatusNotDetermined:
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
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    if (completion)
                    {
                        completion(granted, granted ? VPermissionStateAuthorized : VPermissionStateSystemDenied, nil);
                    }
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
