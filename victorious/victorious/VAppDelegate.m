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

#import "VFacebookManager.h"
#import "VObjectManager+DeviceRegistration.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"
#import "VPushNotificationManager.h"
#import "VUploadManager.h"
#import "VUserManager.h"
#import "VConstants.h"
#import "VSettingManager.h"
#import "VObjectManager.h"
#import "VRootViewController.h"

#import <ADEUMInstrumentation/ADEUMInstrumentation.h>
#import <Crashlytics/Crashlytics.h>

#import "VApplicationTracking.h"
#import "VFlurryTracking.h"
#import "VGoogleAnalyticsTracking.h"
#import "VFirstInstallManager.h"
#import "VPurchaseManager.h"

@import AVFoundation;
@import MediaPlayer;
@import CoreLocation;

static BOOL isRunningTests(void) __attribute__((const));

@implementation VAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (isRunningTests())
    {
        return YES;
    }
    
    // We don't need this yet, but it must be initialized now (see comments for sharedInstance method)
    [VPurchaseManager sharedInstance];
    
    [ADEumInstrumentation initWithKey:@"AD-AAB-AAA-JWA"];
    
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
    
    // Start listening for response to init method from server:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInitResponse:) name:kInitResponseNotification object:nil];
    [VObjectManager setupObjectManager];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[VTrackingManager sharedInstance] addDelegate:[[VApplicationTracking alloc] init]];
    [[VTrackingManager sharedInstance] addDelegate:[[VFlurryTracking alloc] init]];
    [[VTrackingManager sharedInstance] addDelegate:[[VGoogleAnalyticsTracking alloc] init]];
    
#warning This is for testing deep links, make sure to remove before mergin
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [[VRootViewController rootViewController] handleDeeplinkURL:[NSURL URLWithString:@"//comment/11137/4608"]];
    });

    return YES;
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[VRootViewController rootViewController] applicationDidReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    VLog(@"handling events for background identifier: %@", identifier);
    VUploadManager *uploadManager = [[VObjectManager sharedManager] uploadManager];
    if ([uploadManager isYourBackgroundURLSession:identifier])
    {
        uploadManager.backgroundSessionEventsCompleteHandler = completionHandler;
        [uploadManager startURLSession];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[VFacebookManager sharedFacebookManager] canOpenURL:url])
    {
        [[VFacebookManager sharedFacebookManager] openUrl:url];
        return YES;
    }
    
    [[VRootViewController rootViewController] handleDeeplinkURL:url];
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
    
    VTracking *applicationTracking = [VSettingManager sharedManager].applicationTracking;
    
    NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appEnterBackground : @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidEnterBackground parameters:params];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    VTracking *applicationTracking = [VSettingManager sharedManager].applicationTracking;
    
    NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appEnterForeground : @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidEnterForeground parameters:params];
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

#pragma mark - NSNotification handlers

- (void)onInitResponse:(NSNotification *)notification
{
    VTracking *applicationTracking = [VSettingManager sharedManager].applicationTracking;
    
    // Track first install
    [[[VFirstInstallManager alloc] init] reportFirstInstallWithTracking:applicationTracking];
    
    // Tracking init (cold start)
    NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appLaunch : @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidLaunch parameters:params];

    // Only receive this once
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInitResponseNotification object:nil];
}

@end

#pragma mark -

static BOOL isRunningTests(void)
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}
