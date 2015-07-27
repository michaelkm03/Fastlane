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

- (void)trackPermission:(NSString *)trackingStatus
{
    [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueCameraDidAllow permissionState:trackingStatus];
}

@end
