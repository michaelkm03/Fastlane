//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAppDelegate.h"
#import <TestFlightSDK/TestFlight.h>
#import "VThemeManager.h"
#import "VReachability.h"

#import "VAnalyticsRecorder.h"
#import "VFacebookManager.h"
#import "VObjectManager+Analytics.h"
#import "VObjectManager+DeviceRegistration.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"
#import "VPushNotificationManager.h"
#import "VSessionTimer.h"
#import "VUserManager.h"
#import "VDeeplinkManager.h"

#import "VConstants.h"

#import <Crashlytics/Crashlytics.h>

@import AVFoundation;
@import MediaPlayer;
@import CoreLocation;

static NSString * const kAppInstalledDefaultsKey = @"com.victorious.VAppDelegate.AppInstalled";

@implementation VAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight setOptions:@{ TFOptionReportCrashes: @NO }];
#ifdef QA
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightQAToken]];
#elif STAGING
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightStagingToken]];
#elif DEBUG
#else
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightReleaseToken]];
#endif
    
    [Crashlytics startWithAPIKey:@"58f61748f3d33b03387e43014fdfff29c5a1da73"];
    
    [[VThemeManager sharedThemeManager] applyStyling];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[VReachability reachabilityForInternetConnection] startNotifier];

    [VObjectManager setupObjectManager];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAnalytics];
    [[VSessionTimer sharedSessionTimer] start];
    [self reportFirstInstall];
    
    NSURL*  openURL =   launchOptions[UIApplicationLaunchOptionsURLKey];
    if (openURL)
        [[VDeeplinkManager sharedManager] handleOpenURL:openURL];
    
    return YES;
}

- (void)reportFirstInstall
{
    NSNumber *firstInstall = [[NSUserDefaults standardUserDefaults] valueForKey:kAppInstalledDefaultsKey];
    if (![firstInstall boolValue])
    {
        NSDictionary *installEvent = [[VObjectManager sharedManager] dictionaryForInstallEventWithDate:[NSDate date]];
        [[VObjectManager sharedManager] addEvents:@[installEvent]
                                     successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kAppInstalledDefaultsKey];
        }
                                        failBlock:^(NSOperation *operation, NSError *error)
        {
            NSLog(@"Error reporting install event: %@", [error localizedDescription]);
        }];
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:kAppInstalledDefaultsKey];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[VFacebookManager sharedFacebookManager] canOpenURL:url])
    {
        [[VFacebookManager sharedFacebookManager] openUrl:url];
        return YES;
    }
    
    [[VDeeplinkManager sharedManager] handleOpenURL:url];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[VPushNotificationManager sharedPushNotificationManager] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[VPushNotificationManager sharedPushNotificationManager] didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[VThemeManager sharedThemeManager] updateToNewTheme];
    [[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[VThemeManager sharedThemeManager] updateToNewTheme];
    [[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
}

@end
