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

#import "VObjectManager+Environment.h"
#import "VEnvironment.h"
#import "VVoteType.h"
#import "VTracking.h"

//Settings
NSString * const kVCaptureVideoQuality =   @"capture";
NSString * const kVExportVideoQuality =   @"remix";

NSString * const kVRealtimeCommentsEnabled =   @"realtimeCommentsEnabled";
NSString * const kVMemeAndQuoteEnabled =   @"memeAndQuoteEnabled";

NSString * const VSettingsTemplateCEnabled = @"template_c_enabled - 2";
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

- (instancetype)init
{
    self    =   [super init];
    if (self)
    {
        NSURL  *defaultExperimentsURL =   [[NSBundle mainBundle] URLForResource:@"defaultSettings" withExtension:@"plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfURL:defaultExperimentsURL]];
        
        _voteSettings = [[VVoteSettings alloc] init];
    }
    
    return self;
}

- (void)updateSettingsWithAppTracking:(VTracking *)tracking
{
    _applicationTracking = tracking;
}

- (void)updateSettingsWithDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
     }];
}

- (NSURL *)urlForKey:(NSString *)key
{
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSURL *url;
    
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

- (NSString *)emailForKey:(NSString *)key
{
    return nil;
}

- (BOOL)settingEnabledForKey:(NSString *)settingKey
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:settingKey] boolValue];
}

- (NSInteger)variantForExperiment:(NSString *)experimentKey
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:experimentKey] integerValue];
}

- (NSString *)exportVideoQuality
{
    NSString   *value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVExportVideoQuality];
    
    if ([value isEqualToString:@"low"])
    {
        return  AVAssetExportPresetLowQuality;
    }
    else if ([value isEqualToString:@"medium"])
    {
        return  AVAssetExportPresetMediumQuality;
    }
    else if ([value isEqualToString:@"high"])
    {
        return  AVAssetExportPresetHighestQuality;
    }
    else
    {
        return AVAssetExportPresetMediumQuality;
    }
}

- (NSString *)captureVideoQuality
{
    NSString   *value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVCaptureVideoQuality];
    
    if ([value isEqualToString:@"low"])
    {
        return  AVCaptureSessionPresetLow;
    }
    else if ([value isEqualToString:@"medium"])
    {
        return  AVCaptureSessionPresetMedium;
    }
    else if ([value isEqualToString:@"high"])
    {
        return  AVCaptureSessionPresetHigh;
    }
    else
    {
        return AVCaptureSessionPresetMedium;
    }
}

- (NSString *)fetchMonetizationItemByKey:(NSString *)key
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if ([self settingEnabledForKey:key])
    {
        return value;
    }
    
    return @"";
}

@end
