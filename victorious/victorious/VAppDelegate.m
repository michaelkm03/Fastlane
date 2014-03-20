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

#import "VObjectManager+Sequence.h"
#import "VObjectManager+Login.h"
#import "VUserManager.h"

@import MediaPlayer;

@interface VAppDelegate()
@property (nonatomic) BOOL isFullscreen;
@end

@implementation VAppDelegate

+ (VAppDelegate*) sharedAppDelegate
{
    return (VAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand48(time(0));
    
//    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [[VThemeManager sharedThemeManager] applyStyling];

//    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
//    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
//    if (localNotif)
//    {
//        NSString *itemName = [localNotif.userInfo objectForKey:ToDoItemKey];
//        [viewController displayItem:itemName];  // custom method
//        app.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
//    }
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    [VObjectManager setupObjectManager];
    (void)[[VObjectManager sharedManager] initialSequenceLoad];
    [[VObjectManager sharedManager] appInitWithSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VLog(@"Succeeded with objects: %@", resultObjects);
    }
                                                  failBlock:^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
    }];
    
#ifdef STABLE_DEBUG
    [TestFlight takeOff:@"8734f1a7-d756-481a-9234-2be8ba841767"];
#elif DEBUG
    [TestFlight takeOff:@"25d004e5-9530-4969-94e9-f3182e53339b"];
#else
    [TestFlight takeOff:@"02101c7d-4a01-4a44-8e8a-26dca03554aa"];
#endif
    
//    [[VUserManager sharedInstance] silentlyLogin];
    
    // Initialize the chromecast device controller.
    self.chromecastDeviceController = [[ChromecastDeviceController alloc] init];
    
    // Scan for devices.
    [self.chromecastDeviceController performScan:YES];

    NSURL*  openURL =   launchOptions[UIApplicationLaunchOptionsURLKey];
    if (openURL)
        [self handleOpenURL:openURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enteredFullscreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exitedFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];

    

    return YES;
}

- (void)enteredFullscreen:(NSNotification*)notif
{
    self.isFullscreen = YES;
}

- (void)exitedFullscreen:(NSNotification*)notif
{
    self.isFullscreen = NO;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.isFullscreen)
        return UIInterfaceOrientationMaskLandscape;
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self handleOpenURL:url];
    return YES;
}

//Deep link handler
- (void)handleOpenURL:(NSURL *)aURL
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext save:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext save:nil];
}

//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//    
//    NSURL *url = [[NSURL alloc] initWithString:@"http://yourserver.com/data.json"];
//    NSURLSessionDataTask *task = [session dataTaskWithURL:url
//                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//    {
//        if (error)
//        {
//            completionHandler(UIBackgroundFetchResultFailed);
//            return;
//        }
//                                            
//        // Parse response/data and determine whether new content was available
//        BOOL hasNewData = NO;
//        if (hasNewData)
//        {
//            completionHandler(UIBackgroundFetchResultNewData);
//        }
//        else
//        {
//            completionHandler(UIBackgroundFetchResultNoData);
//        }
//    }];
//    
//    // Start the task
//    [task resume];
//}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSLog(@"Remote Notification userInfo is %@", userInfo);
//    
////    NSNumber *contentID = userInfo[@"content-id"];
//    // Do something with the content ID
//    completionHandler(UIBackgroundFetchResultNewData);
//}

//- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
//{
////    const void *devTokenBytes = [devToken bytes];
////    self.registered = YES;
////    [self sendProviderDeviceToken:devTokenBytes]; // custom method
//}

//- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
//{
//    NSLog(@"Error in registration. Error: %@", err);
//}

@end
