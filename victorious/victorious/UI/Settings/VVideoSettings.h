//
//  VVideoSettings.h
//  victorious
//
//  Created by Patrick Lynch on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM( NSUInteger, VAutoplaySetting )
{
    VAutoplaySettingAlways,
    VAutoplaySettingOnlyOnWifi,
    VAutoplaySettingNever,
    VAutoplaySettingCount
};


@interface VVideoSettings : UIViewController

+ (NSString *)displayNameForSetting:(VAutoplaySetting)setting;

+ (void)setAutoPlaySetting:(VAutoplaySetting)setting;

+ (VAutoplaySetting)autoplaySetting;

+ (BOOL)isAutoplayEnabled;

@end
