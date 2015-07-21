//
//  VPermissionProfilePicture.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionProfilePicture.h"
#import "VAppInfo.h"

@import AVFoundation;

@implementation VPermissionProfilePicture

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"profileImagePermission.message"];
    return NSLocalizedString(message, @"");
}


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

@end
