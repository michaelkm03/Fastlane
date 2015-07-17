//
//  VPermissionsTrackingHelper.m
//  victorious
//
//  Created by Steven F Petteruti on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionsTrackingHelper.h"
#import "VTracking.h"
#import "VPermissionCamera.h"
#import "VPermissionMicrophone.h"
#import "VPermissionPhotoLibrary.h"
#import "VFacebookManager.h"
#import "VTwitterManager.h"
#import "VNotificationSettings.h"
#import "VLocationManager.h"

@implementation VPermissionsTrackingHelper

- (void)permissionsDidChange:(NSString *)permissionName permissionState:(NSString *)permissionState
{
    NSDictionary *params = @{ VTrackingKeyPermissionState : permissionState,
                               VTrackingKeyPermissionName : permissionName};
    NSLog(@"params: %@", params);

    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserPermissionDidChange parameters:params];
}

@end
