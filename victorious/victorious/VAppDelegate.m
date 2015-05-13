//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAppDelegate.h"
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
#import "VObjectManager.h"
#import "VRootViewController.h"

#import <ADEUMInstrumentation/ADEUMInstrumentation.h>
#import <Crashlytics/Crashlytics.h>

#import "VApplicationTracking.h"
#import "VFlurryTracking.h"
#import "VGoogleAnalyticsTracking.h"
#import "VPurchaseManager.h"
#import "UIStoryboard+VMainStoryboard.h"

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
    
#ifndef DEBUG
    [ADEumInstrumentation initWithKey:@"AD-AAB-AAA-JWA"];
#endif
    
    [Crashlytics startWithAPIKey:@"58f61748f3d33b03387e43014fdfff29c5a1da73"];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[VReachability reachabilityForInternetConnection] startNotifier];
    
    [VObjectManager setupObjectManager];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[VTrackingManager sharedInstance] addDelegate:[[VApplicationTracking alloc] init]];
    [[VTrackingManager sharedInstance] addDelegate:[[VGoogleAnalyticsTracking alloc] init]];
    
    VFlurryTracking *flurryTracking = [[VFlurryTracking alloc] init];
    flurryTracking.unwantedParameterKeys = @[ VTrackingKeySequenceId, VTrackingKeyStreamId, VTrackingKeyTimeStamp ];
    [[VTrackingManager sharedInstance] addDelegate:flurryTracking];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[VRootViewController rootViewController] applicationDidReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    VLog(@"handling events for background identifier: %@", identifier);
    VUploadManager *uploadManager = [VUploadManager sharedManager];
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
    
    [[VRootViewController rootViewController].deepLinkReceiver receiveDeeplink:url];
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
    [[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
}

@end

#pragma mark -

static BOOL isRunningTests(void)
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}
