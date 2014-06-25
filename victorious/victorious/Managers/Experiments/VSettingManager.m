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

//Settings
NSString*   const   kVCaptureVideoQuality               =   @"capture";
NSString*   const   kVExportVideoQuality                =   @"remix";

//URLs
NSString*   const   kVTermsOfServiceURL                 =   @"url.tos";
NSString*   const   kVAppStoreURL                       =   @"url.appstore";
NSString*   const   kVPrivacyUrl                        =   @"url.privacy";

NSString*   const   kVChannelURLSupport                 =   @"email.support";

@implementation VSettingManager

+ (instancetype)sharedManager
{
    static  VSettingManager*  sharedManager;
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
        NSURL*  defaultExperimentsURL =   [[NSBundle mainBundle] URLForResource:@"defaultSettings" withExtension:@"plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfURL:defaultExperimentsURL]];
    }
    
    return self;
}

- (void)updateSettingsWithDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
     }];
}

- (NSURL*)urlForKey:(NSString*)key
{
    NSString* path = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSURL* url;
    
    //If it contains :// its a valid URL
    if ([path rangeOfString:@"://"].length)
        url = [NSURL URLWithString:path];
    else
        url = [VObjectManager addExtensionToBaseURL:path];
    
    return url;
}

- (NSString*)emailForKey:(NSString*)key
{
    return nil;
}

- (NSInteger)variantForExperiment:(NSString*)experimentKey
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:experimentKey] integerValue];
}

- (NSString *)exportVideoQuality
{
    NSString*   value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVExportVideoQuality];
    
    if ([value isEqualToString:@"low"])
        return  AVAssetExportPresetLowQuality;
    else if ([value isEqualToString:@"medium"])
        return  AVAssetExportPresetMediumQuality;
    else if ([value isEqualToString:@"high"])
        return  AVAssetExportPresetHighestQuality;
    else
        return AVAssetExportPresetMediumQuality;
}

- (NSString *)captureVideoQuality
{
    NSString*   value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVCaptureVideoQuality];
    
    if ([value isEqualToString:@"low"])
        return  AVCaptureSessionPresetLow;
    else if ([value isEqualToString:@"medium"])
        return  AVCaptureSessionPresetMedium;
    else if ([value isEqualToString:@"high"])
        return  AVCaptureSessionPresetHigh;
    else
        return AVCaptureSessionPresetMedium;
}

@end
