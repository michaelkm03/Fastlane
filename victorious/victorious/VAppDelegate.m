//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "TestFairy.h"
#import "VAppDelegate.h"
#import "VReachability.h"
#import "VPushNotificationManager.h"
#import "VUploadManager.h"
#import "VConstants.h"
#import "VRootViewController.h"
#import "VStoredLogin.h"
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
    if ([NSBundle v_isTestBundle])
    {
        return YES;
    }
    
    // We don't need this yet, but it must be initialized now (see comments for sharedInstance method)
    [VPurchaseManager sharedInstance];
    
#if V_ENABLE_TESTFAIRY
    [TestFairy begin:@"c03fa570f9415585437cbfedb6d09ae87c7182c8" withOptions:@{ TFSDKEnableCrashReporterKey: @NO }];
    [self addLoginListener];
#endif
    
    if (![AgeGate isAgeGateEnabled])
    {
        [Crashlytics startWithAPIKey:@"58f61748f3d33b03387e43014fdfff29c5a1da73"];
    }
    
    [[VReachability reachabilityForInternetConnection] startNotifier];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    DefaultTimingTracker *appTimingTracker = [DefaultTimingTracker sharedInstance];
    [appTimingTracker startEventWithType:VAppTimingEventTypeAppStart subtype:nil];
    [appTimingTracker startEventWithType:VAppTimingEventTypeShowRegistration subtype:nil];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[VRootViewController sharedRootViewController] applicationDidReceiveRemoteNotification:userInfo];
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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options
{
    if ( [VFacebookHelper canOpenURL:url] )
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                              openURL:url
                                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                           annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    [[VRootViewController sharedRootViewController] applicationOpenURL:url
                                                     sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                            annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
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
    id<PersistentStoreType> persistentStore = [PersistentStoreSelector defaultPersistentStore];
    [[persistentStore mainContext] save:nil];
}

#ifdef V_ENABLE_TESTFAIRY
- (void)addLoginListener
{
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoggedInChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *_Nonnull notification)
    {
        VUser *user = [VCurrentUser user];
        if ( user != nil )
        {
            [TestFairy identify:[user.remoteId stringValue] traits:@{TFSDKIdentityTraitNameKey: user.name ?: @"",
                                                                     TFSDKIdentityTraitEmailAddressKey: user.email ?: @"",
                                                                     }];
        }
    }];
}
#endif

@end
