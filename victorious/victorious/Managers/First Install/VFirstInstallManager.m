//
//  VFirstInstallManager.m
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFirstInstallManager.h"
#import "VObjectManager+Analytics.h"

NSString * const VAppInstalledDefaultsKey = @"com.victorious.VAppDelegate.AppInstalled";

@implementation VFirstInstallManager

- (void)reportFirstInstall
{
    id userDefaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey];
    if ( userDefaultsValue != nil )
    {
        return;
    }
    
    [self trackEventWithOldMethod];
    [self trackEvent];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:VAppInstalledDefaultsKey];
}

- (void)trackEvent
{
    // Modern tracking
    NSDate *installDate = [NSDate date];
    NSDictionary *params = @{ VTrackingKeyTimeStamp : installDate };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationFirstInstall parameters:params];
}

- (void)trackEventWithOldMethod
{
    // Deprecated tracking using "/api/events/add" endpoint
    VObjectManager *objManager = [VObjectManager sharedManager];
    NSDictionary *installEvent = [objManager dictionaryForInstallEventWithDate:[NSDate date]];
    [[VObjectManager sharedManager] addEvents:@[installEvent] successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:VAppInstalledDefaultsKey];
     }
                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         NSLog(@"Error reporting install event: %@", [error localizedDescription]);
     }];
}

@end
