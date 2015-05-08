//
//  VFirstInstallManager.m
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFirstInstallManager.h"
#import "VObjectManager+Analytics.h"
#import "VTracking.h"

NSString * const VAppInstalledOldTrackingDefaultsKey = @"com.victorious.VAppDelegate.AppInstalled";
NSString * const VAppInstalledDefaultsKey = @"com.victorious.VAppDelegate.AppInstallEventTracked";

@implementation VFirstInstallManager

- (void)reportFirstInstallWithTrackingURLs:(NSArray *)applicationTrackingURLs
{
    // Check for value indicating app has already been installed before
    id userDefaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey];
    if ( userDefaultsValue != nil )
    {
        return;
    }
    
    // Check again using the old key from previous versions, otherwise installs will be re-reported
    // when users update to newer versions
    id userDefaultsOldValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey];
    if ( userDefaultsOldValue != nil )
    {
        return;
    }
    
    // Resport the install event
    NSDate *installDate = [NSDate date];
    NSArray *urls = applicationTrackingURLs ?: @[];
    NSDictionary *params = @{ VTrackingKeyTimeStamp : installDate , VTrackingKeyUrls : urls };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationFirstInstall parameters:params];
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VAppInstalledDefaultsKey];
}

@end
