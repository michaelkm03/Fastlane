//
//  VDependencyManager+VTracking.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VTracking.h"

NSString * const VTrackingStartKey                      = @"start";
NSString * const VTrackingStopKey                       = @"stop";
NSString * const VTrackingInitKey                       = @"init";
NSString * const VTrackingInstallKey                    = @"install";
NSString * const VTrackingCreateProfileStartKey         = @"create_profile_start";
NSString * const VTrackingRegistrationEndKey            = @"registration_end";
NSString * const VTrackingRegistrationStartKey          = @"registration_start";
NSString * const VTrackingCreateProfileDoneButtonTapKey = @"create_profile_done_button_tap";
NSString * const VTrackingRegisteButtonTapKey           = @"register_button_tap";
NSString * const VTrackingSignUpButtonTapKey            = @"sign_up_button_tap";
NSString * const VTrackingPermissionChangeKey           = @"permission_change";
NSString * const VTrackingAppErrorKey                   = @"error";

static NSString * const kTrackingTimingKey              = @"app_time";
static NSString * const kTrackingViewKey                = @"view";
