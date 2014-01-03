//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAppDelegate.h"
#import "VObjectManager.h"
//#import "VLoginViewController.h"
#import <TestFlightSDK/TestFlight.h>
#import "VThemeManager.h"

#import "VObjectManager.h"
#import "VObjectManager+Sequence.h"
#import "VMenuTableViewController.h"
#import "VSettingsViewController.h"

@implementation VAppDelegate

+ (VAppDelegate*) sharedAppDelegate
{
    return (VAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    application.statusBarStyle  =   UIStatusBarStyleLightContent;

    self.window.tintColor   =   [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];

    [[UINavigationBar appearance] setTintColor:[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.navigationBar"]];
    [[UINavigationBar appearance] setBarTintColor:[[VThemeManager sharedThemeManager] themedTranslucencyColorForKeyPath:@"theme.color.navigationBar.background"]];

    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.navigationBar.title"];
    if(navigationBarTitleTintColor){
        [titleAttributes setObject:navigationBarTitleTintColor forKey:NSForegroundColorAttributeName];
    }
    UIFont *navigationBarTitleFont = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.navigationBar.title"];
    if(navigationBarTitleFont){
        [titleAttributes setObject:navigationBarTitleFont forKey:NSFontAttributeName];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];


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
    [[[VObjectManager sharedManager] initialSequenceLoad] start];

    [TestFlight takeOff:@"4467aa06-d174-479e-b009-f1945f3d6532"];

    
    NSURL*  openURL =   launchOptions[UIApplicationLaunchOptionsURLKey];
    if (openURL)
        [self handleOpenURL:openURL];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidSelectRow:) name:VMenuTableViewControllerDidSelectRowNotification object:nil];

    return YES;
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

- (void)menuDidSelectRow:(NSNotification *)notification{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    switch((VMenuTableViewControllerRow)[notification.object integerValue]){
        case VMenuTableViewControllerRowHome:{
            // TODO: show home
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowOwnerChannel:{
            // TODO: show owner channel
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowCommunityChannel:{
            // TODO: show community channel
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowForums:{
            // TODO: show forums
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowInbox:{
            // TODO: show inbox
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowProfile:{
            // TODO: show profile
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowSettings:{
            navigationController.viewControllers = @[[VSettingsViewController sharedSettingsViewController]];
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowHelp:{
            // TODO: show help
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }

    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://yourserver.com/data.json"];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            completionHandler(UIBackgroundFetchResultFailed);
            return;
        }
                                            
        // Parse response/data and determine whether new content was available
        BOOL hasNewData = NO;
        if (hasNewData)
        {
            completionHandler(UIBackgroundFetchResultNewData);
        }
        else
        {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
    
    // Start the task
    [task resume];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Remote Notification userInfo is %@", userInfo);
    
//    NSNumber *contentID = userInfo[@"content-id"];
    // Do something with the content ID
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
//    const void *devTokenBytes = [devToken bytes];
//    self.registered = YES;
//    [self sendProviderDeviceToken:devTokenBytes]; // custom method
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
}

@end
