//
//  VFirstInstallManager.m
//  victorious
//
//  Created by Patrick Lynch on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFirstInstallManager.h"

NSString * const VAppInstalledOldTrackingDefaultsKey = @"com.victorious.VAppDelegate.AppInstalled";
NSString * const VAppInstalledDefaultsKey            = @"com.victorious.VAppDelegate.AppInstallEventTracked";

@implementation VFirstInstallManager

- (void)reportFirstInstall
{
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VAppInstalledDefaultsKey];
}

- (BOOL)hasFirstInstallBeenTracked
{
    // Check for value indicating app has already been installed before
    id userDefaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey];
    if ( userDefaultsValue != nil )
    {
        return YES;
    }
    
    // Check again using the old key from previous versions, otherwise installs will be re-reported
    // when users update to newer versions
    id userDefaultsOldValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey];
    if ( userDefaultsOldValue != nil )
    {
        return YES;
    }
    
    return NO;
}

@end
