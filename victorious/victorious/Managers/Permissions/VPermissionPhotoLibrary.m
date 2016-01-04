//
//  VPermissionPhotoLibrary.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionPhotoLibrary.h"

@import Photos;

@implementation VPermissionPhotoLibrary

- (VPermissionState)permissionState
{
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    switch (authorizationStatus)
    {
        case PHAuthorizationStatusNotDetermined:
            return VPermissionStateUnknown;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            return VPermissionStateSystemDenied;
        case PHAuthorizationStatusAuthorized:
            return VPermissionStateAuthorized;
    }
}

- (void)trackPermission:(NSString *)trackingStatus
{
    [self.permissionsTrackingHelper permissionsDidChange:VTrackingValuePhotolibraryDidAllow permissionState:trackingStatus];
}

- (void)requestSystemPermissionWithCompletion:(VPermissionRequestCompletionHandler)completion
{
    // Completion handler is required
    NSParameterAssert(completion != nil);
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (status == PHAuthorizationStatusAuthorized)
            {
                completion(YES, [self permissionState], nil);
                [self trackPermission:VTrackingValueAuthorized];
            }
            else
            {
                completion(NO, [self permissionState], nil);
                [self trackPermission:VTrackingValueDenied];
            }
        });
    }];
}

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"photoLibraryPermission.message"];
    if (message != nil && message.length > 0)
    {
        return message;
    }
    return NSLocalizedString(@"We need permission to access your photo library.", @"");
}

@end
