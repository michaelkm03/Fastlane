//
//  VPermissionProfilePicture.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionProfilePicture.h"
#import "VAppInfo.h"

@implementation VPermissionProfilePicture

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"profileImagePermission.message"];
    return NSLocalizedString(message, @"");
}


- (VPermissionState)permissionState
{
    // subclasses must override
    return VPermissionStateUnknown;
}


- (void)trackPermission:(NSString *)trackingStatus
{
    [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueCameraDidAllow permissionState:trackingStatus];
}

@end
