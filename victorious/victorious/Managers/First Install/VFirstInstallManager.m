//
//  VFirstInstallManager.m
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFirstInstallManager.h"
#import "VObjectManager+Analytics.h"

NSString * const VAppInstalledOldTrackingDefaultsKey = @"com.victorious.VAppDelegate.AppInstalled";
NSString * const VAppInstalledDefaultsKey = @"com.victorious.VAppDelegate.AppInstallEventTracked";

@implementation VFirstInstallManager

- (void)reportFirstInstall
{
    [self trackEventWithOldMethod];
    [self trackEvent];
}

- (void)trackEvent
{
    id userDefaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey];
    if ( userDefaultsValue != nil )
    {
        return;
    }
    
    // Modern tracking
    NSDate *installDate = [NSDate date];
    NSDictionary *params = @{ VTrackingKeyTimeStamp : installDate };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationFirstInstall parameters:params];
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VAppInstalledDefaultsKey];
}

- (void)trackEventWithOldMethod
{
    id userDefaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey];
    if ( userDefaultsValue != nil )
    {
        return;
    }
    
    // Deprecated tracking using "/api/events/add" endpoint
    VObjectManager *objManager = [VObjectManager sharedManager];
    NSDictionary *installEvent = [objManager dictionaryForInstallEventWithDate:[NSDate date]];
    [objManager addEvents:@[installEvent] successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VAppInstalledOldTrackingDefaultsKey];
    }
                                    failBlock:nil];
}

@end
