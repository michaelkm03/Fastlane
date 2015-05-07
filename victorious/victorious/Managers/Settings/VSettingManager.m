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

//Experiments
NSString * const VExperimentsPauseVideoWhenCommenting = @"pauseVideoWhenCommenting";
NSString * const VExperimentsClearVideoBackground = @"clearVideoBackground";

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
    
    if (path == nil)
    {
        return nil;
    }
    
    NSURL *url;
    
    if (path == nil)
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
    NSNumber *settingValue = [self.dependencyManager numberForKey:VDependencyManagerProfileImageRequiredKey];
    return settingValue == nil ? NO : [settingValue boolValue];
}

@end
