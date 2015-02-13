//
//  VVideoSettings.m
//  victorious
//
//  Created by Patrick Lynch on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSettings.h"
#import "VReachability.h"

static NSString * const kVideoAutoplaySettingKey = @"com.getvictorious.settings.videoAutoplay";

@implementation VVideoSettings

- (NSString *)displayNameForSetting:(VAutoplaySetting)setting
{
    switch (setting)
    {
        case VAutoplaySettingAlways:
            return NSLocalizedString( @"Always", @"Setting indicating auto play every time." );
        case VAutoplaySettingOnlyOnWifi:
            return NSLocalizedString( @"Only on Wifi", @"Setting indicating auto play only with a Wifi connection." );
        case VAutoplaySettingNever:
            return NSLocalizedString( @"Never", @"Setting indicating auto play never happens." );
        default:
            break;
    }
    
    return nil;
}

- (NSString *)displayNameForCurrentSetting
{
    VAutoplaySetting currentAutoplaySetting = [self autoplaySetting];
    return [self displayNameForSetting:currentAutoplaySetting];
}

- (void)setAutoPlaySetting:(VAutoplaySetting)setting
{
    [[NSUserDefaults standardUserDefaults] setObject:@(setting) forKey:kVideoAutoplaySettingKey];
}

- (VAutoplaySetting)autoplaySetting
{
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoAutoplaySettingKey];
    if ( [value isKindOfClass:[NSNumber class]] )
    {
        NSUInteger integerValue = [((NSNumber *)value) unsignedIntegerValue];
        if ( integerValue > 0 && integerValue < VAutoplaySettingCount )
        {
            return (VAutoplaySetting)integerValue;
        }
    }
    
    return VAutoplaySettingAlways;
}

- (BOOL)isAutoplayEnabled
{
    VAutoplaySetting currentSetting = [self autoplaySetting];
    switch ( currentSetting )
    {
        case VAutoplaySettingOnlyOnWifi:
        {
            VReachability *reachability = [VReachability reachabilityForInternetConnection];
            VNetworkStatus status = [reachability currentReachabilityStatus];
            return status == VNetworkStatusReachableViaWiFi;
        }
            
        case VAutoplaySettingNever:
            return NO;
            
        default:
        case VAutoplaySettingAlways:
            return YES;
    }
}

@end
