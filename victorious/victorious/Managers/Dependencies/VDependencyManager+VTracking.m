//
//  VDependencyManager+VTracking.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VTracking.h"

NSString * const VTrackingStartKey              = @"start";
NSString * const VTrackingStopKey               = @"stop";
NSString * const VTrackingInitKey               = @"init";
NSString * const VTrackingInstallKey            = @"install";
NSString * const VTrackingBallisticCountKey     = @"ballistic_count";
NSString * const VTrackingCreateProfileStart    = @"create_profile_start";
NSString * const VTrackingFirstBoot             = @"first_boot";
NSString * const VTrackingRegistrationEnd       = @"registration_end";
NSString * const VTrackingRegistrationStart     = @"registration_start";
NSString * const VTrackingGetStartedTap         = @"get_started_tap";
NSString * const VTrackingDoneButtonTap         = @"done_button_tap";
NSString * const VTrackingRegisteButtonTap      = @"register_button_tap";
NSString * const VTrackingSignUpButtonTap       = @"sign_up_button_tap";
NSString * const VTrackingWelcomeVideoStart     = @"welcome_video_start";
NSString * const VTrackingWelcomeVideoEnd       = @"welcome_video_end";
NSString * const VTrackingWelcomeStart          = @"welcome_start";

static NSString * const kTrackingKey            = @"tracking";

@implementation VDependencyManager (VTracking)

- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey
{
    NSDictionary *tracking = [self templateValueOfType:[NSDictionary class] forKey:kTrackingKey];
    return tracking[ eventURLKey ] ?: @[];
}

@end
