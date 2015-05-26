//
//  VDependencyManager+VTracking.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VTracking.h"

NSString * const VTrackingStartKey                 = @"start";
NSString * const VTrackingStopKey                  = @"stop";
NSString * const VTrackingInitKey                  = @"init";
NSString * const VTrackingInstallKey               = @"install";
NSString * const VTrackingBallisticCountKey        = @"ballistic_count";
NSString * const VTrackingCreateProfileStartKey    = @"create_profile_start";
NSString * const VTrackingFirstBootKey             = @"first_boot";
NSString * const VTrackingRegistrationEndKey       = @"registration_end";
NSString * const VTrackingRegistrationStartKey     = @"registration_start";
NSString * const VTrackingGetStartedTapKey         = @"get_started_tap";
NSString * const VTrackingDoneButtonTapKey         = @"done_button_tap";
NSString * const VTrackingRegisteButtonTapKey      = @"register_button_tap";
NSString * const VTrackingSignUpButtonTapKey       = @"sign_up_button_tap";
NSString * const VTrackingWelcomeVideoStartKey     = @"welcome_video_start";
NSString * const VTrackingWelcomeVideoEndKey       = @"welcome_video_end";
NSString * const VTrackingWelcomeStartKey          = @"welcome_start";

static NSString * const kTrackingKey                = @"tracking";

@implementation VDependencyManager (VTracking)

- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey
{
    NSDictionary *tracking = [self templateValueOfType:[NSDictionary class] forKey:kTrackingKey];
    return tracking[ eventURLKey ] ?: @[];
}

@end
