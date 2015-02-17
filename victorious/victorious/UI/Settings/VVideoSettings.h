//
//  VVideoSettings.h
//  victorious
//
//  Created by Patrick Lynch on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Values for the autoplay setting that determine when autoplay of
 the next video in a stream or playlist should be enabled.
 */
typedef NS_ENUM( NSUInteger, VAutoplaySetting )
{
    VAutoplaySettingAlways,
    VAutoplaySettingOnlyOnWifi,
    VAutoplaySettingNever,
    VAutoplaySettingCount
};

@interface VVideoSettings : NSObject

/**
 Returns a localized string representing the user-facing display name of the provided setting.
 */
- (NSString *)displayNameForSetting:(VAutoplaySetting)setting;

/**
 Returns a localized string representing the user-facing display name of the current setting.
 */
- (NSString *)displayNameForCurrentSetting;

/**
 Set the current setting, usually in response to a user actions.
 */
- (void)setAutoPlaySetting:(VAutoplaySetting)setting;

/**
 Get the current autoplay setting.
 */
- (VAutoplaySetting)autoplaySetting;

/**
 A simple flag that handles checking the current internet connection and 
 the autoplay setting to let calling code know if autoplay should be enabled.
 */
- (BOOL)isAutoplayEnabled;

@end
