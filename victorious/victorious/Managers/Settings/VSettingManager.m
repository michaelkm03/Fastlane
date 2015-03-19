//
//  VExperimentManager.m
//  victorious
//
//  Created by Will Long on 6/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSettingManager.h"
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVCaptureSession.h>

#import "VDependencyManager.h"
#import "VObjectManager+Environment.h"
#import "VEnvironment.h"
#import "VVoteType.h"
#import "VTracking.h"

//Settings
NSString * const kVCaptureVideoQuality =   @"capture";
NSString * const kVExportVideoQuality =   @"remix";

NSString * const VSettingsTemplateCEnabled = @"template_c_enabled";
NSString * const VSettingsTemplateDEnabled = @"template_d_enabled";
NSString * const VSettingsChannelsEnabled = @"channels_enabled";
NSString * const VSettingsMarqueeEnabled = @"marqueeEnabled";

//Experiments
NSString * const VExperimentsRequireProfileImage = @"require_profile_image";
NSString * const VExperimentsPauseVideoWhenCommenting = @"pause_video_when_commenting";
NSString * const VExperimentsClearVideoBackground = @"clear_video_background";

//Monetization
NSString * const kLiveRailPublisherId = @"monetization.LiveRailsPublisherID";
NSString * const kOpenXVastTag = @"monetization.OpenXVastTag";

//URLs
NSString * const kVTermsOfServiceURL = @"url.tos";
NSString * const kVAppStoreURL = @"url.appstore";
NSString * const kVPrivacyUrl = @"url.privacy";

@implementation VSettingManager

+ (instancetype)sharedManager
{
    static  VSettingManager  *sharedManager;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedManager = [[self alloc] init];
                  });
    
    return sharedManager;
}

- (NSURL *)urlForKey:(NSString *)key
{
    NSString *path = [self.dependencyManager stringForKey:key];
    
    NSURL *url;
    
    if ( path == nil )
    {
        return nil;
    }
    
    //If it contains :// its a valid URL
    if ([path rangeOfString:@"://"].length)
    {
        url = [NSURL URLWithString:path];
    }
    else
    {
        url = [[VObjectManager currentEnvironment].baseURL URLByAppendingPathComponent:path];
    }
    
    return url;
}

- (BOOL)settingEnabledForKey:(NSString *)settingKey
{
    return [[self.dependencyManager numberForKey:settingKey] boolValue];
}

@end
