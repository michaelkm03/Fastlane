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

- (void)trackPermission:(NSString *)trackingStatus
{
    [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueCameraDidAllow permissionState:trackingStatus];
}

- (void)requestSystemPermissionWithCompletion:(VPermissionRequestCompletionHandler)completion
{
    // Completion handler is required
    NSParameterAssert(completion != nil);
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            completion(granted, granted ? VPermissionStateAuthorized : VPermissionStateSystemDenied, nil);
                        });
     }];
}

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"cameraPermission.message"];
    return NSLocalizedString(message, @"");
}

@end
