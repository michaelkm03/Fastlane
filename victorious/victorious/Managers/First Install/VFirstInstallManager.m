//
//  VFirstInstallManager.m
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFirstInstallManager.h"
#import "VObjectManager+Analytics.h"

static NSString * const kAppInstalledDefaultsKey = @"com.victorious.VAppDelegate.AppInstalled";

@implementation VFirstInstallManager

- (void)reportFirstInstall
{
    NSDate *installDate = [[NSUserDefaults standardUserDefaults] valueForKey:kAppInstalledDefaultsKey];
    if ( installDate == nil )
    {
        installDate = [NSDate date];
        NSDictionary *params = @{ VTrackingKeyTimeStamp : installDate };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationFirstInstall parameters:params];
        [[NSUserDefaults standardUserDefaults] setValue:installDate forKey:kAppInstalledDefaultsKey];
    }
}

- (void)reportFirstInstallWithOldTracking
{
    NSDate *installDate = [[NSUserDefaults standardUserDefaults] valueForKey:kAppInstalledDefaultsKey];
    if ( installDate == nil )
    {
        installDate = [NSDate date];
        NSDictionary *installEvent = [[VObjectManager sharedManager] dictionaryForInstallEventWithDate:installDate];
        [[VObjectManager sharedManager] addEvents:@[installEvent] successBlock:nil failBlock:nil];
        [[NSUserDefaults standardUserDefaults] setValue:installDate forKey:kAppInstalledDefaultsKey];
    }
}

@end
