//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VAppDelegate.h"
#import "VObjectManager.h"
#import "VLoginViewController.h"
#import <TestFlightSDK/TestFlight.h>
#import "VSequenceManager.h"
#import "VObjectManager.h"

@implementation VAppDelegate

+ (VAppDelegate*) sharedAppDelegate
{
    return (VAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [VObjectManager setupObjectManager];

    [[[VObjectManager sharedManager] createVictoriousAccountWithEmail:@"ab@a.com" password:@"a" name:@"a" block:^(VUser *user, NSError *error){
        NSLog(@"%@", user);
        NSLog(@"%@", error);
    }] start];

    [TestFlight takeOff:@"4467aa06-d174-479e-b009-f1945f3d6532"];
    
    //[VLoginManager createVictoriousAccountWithEmail:@"a" password:@"a" name:@"a"];
    //[VLoginManager loginToVictoriousWithEmail:@"a" andPassword:@"a"];
//    [VLoginManager loginToFacebook];
    
    return YES;
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

@end
