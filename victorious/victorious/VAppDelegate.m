//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAppDelegate.h"
#import "VReachability.h"

#import "VObjectManager+DeviceRegistration.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"
#import "VPushNotificationManager.h"
#import "VUploadManager.h"
#import "VConstants.h"
#import "VObjectManager.h"
#import "VRootViewController.h"

#import <Crashlytics/Crashlytics.h>

#import "VPurchaseManager.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "victorious-Swift.h"

@import AVFoundation;
@import FBSDKCoreKit;
@import MediaPlayer;
@import CoreLocation;

@implementation VAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ( ![self shouldCompleteLaunch] )
    {
        return YES;
    }
    
    // We don't need this yet, but it must be initialized now (see comments for sharedInstance method)
    [VPurchaseManager sharedInstance];
    
    [Crashlytics startWithAPIKey:@"58f61748f3d33b03387e43014fdfff29c5a1da73"];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[VReachability reachabilityForInternetConnection] startNotifier];
    
    [VObjectManager setupObjectManagerWithUploadManager:[VUploadManager sharedManager]];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if ( localNotification != nil )
    {
        [[VRootViewController rootViewController] handleLocalNotification:localNotification];
    }
    
    DefaultTimingTracker *appTimingTracker = [DefaultTimingTracker sharedInstance];
    [appTimingTracker startEventWithType:VAppTimingEventTypeAppStart subtype:nil];
    [appTimingTracker startEventWithType:VAppTimingEventTypeShowRegistration subtype:nil];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)localNotification
{
    if ( [application applicationState] == UIApplicationStateInactive )
    {
        [[VRootViewController rootViewController] handleLocalNotification:localNotification];
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
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
    if ( [VFacebookHelper canOpenURL:url] )
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    [[VRootViewController rootViewController] applicationOpenURL:url sourceApplication:sourceApplication annotation:annotation];
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
    [self savePersistentChanges];
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
    [self savePersistentChanges];
}

- (void)savePersistentChanges
{
    // Save any changes in the main context to ensure it saves to disk and is available upon next app launch
    id<PersistentStoreType> persistentStore = [[MainPersistentStore alloc] init];
}

#pragma mark - Testing Helpers

- (BOOL)shouldCompleteLaunch
{
    NSBundle *testBundle = [self testBundle];
    if ( testBundle != nil )
    {
        NSNumber *shouldCompleteLaunchObject = [testBundle objectForInfoDictionaryKey:@"VShouldCompleteLaunch"];
        return shouldCompleteLaunchObject == nil ? NO : shouldCompleteLaunchObject.boolValue;
    }
    return YES;
}

- (nullable NSBundle *)testBundle
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundlePath = environment[@"XCInjectBundle"];
    
    if ( [[injectBundlePath pathExtension] isEqualToString:@"xctest"] )
    {
        NSBundle *bundleInCorrectLocation = [NSBundle bundleWithPath:injectBundlePath];

        if ( bundleInCorrectLocation != nil )
        {
            return bundleInCorrectLocation;
        }
        NSString *bundleName = [injectBundlePath lastPathComponent];
        NSString *alternateBundlePath = [NSTemporaryDirectory() stringByAppendingPathComponent:bundleName];
        return [NSBundle bundleWithPath:alternateBundlePath];
    }
    return nil;
}

@end
