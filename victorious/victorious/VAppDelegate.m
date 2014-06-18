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
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUserManager.h"
#import "VDeeplinkManager.h"

#import "VConstants.h"

@import MediaPlayer;
@import CoreLocation;

@interface VAppDelegate ()  <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager*            locationManager;
@property (nonatomic, strong) CLGeocoder*                   geoCoder;
@end

@implementation VAppDelegate

+ (VAppDelegate*) sharedAppDelegate
{
    return (VAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand48(time(0));

    [[VThemeManager sharedThemeManager] applyStyling];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[VReachability reachabilityForInternetConnection] startNotifier];

    [VObjectManager setupObjectManager];

#ifdef QA
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightQAToken]];
#elif STAGING
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightStagingToken]];
#elif DEBUG
#else
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightReleaseToken]];
#endif
    
    // Initialize the chromecast device controller.
    self.chromecastDeviceController = [[ChromecastDeviceController alloc] init];
    
    // Scan for devices.
    [self.chromecastDeviceController performScan:YES];

    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAnalytics];
    
    NSURL*  openURL =   launchOptions[UIApplicationLaunchOptionsURLKey];
    if (openURL)
        [[VDeeplinkManager sharedManager] handleOpenURL:openURL];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[VDeeplinkManager sharedManager] handleOpenURL:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[VThemeManager sharedThemeManager] updateToNewTheme];
    [[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext saveToPersistentStore:nil];
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
    [[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext saveToPersistentStore:nil];
}

@end
