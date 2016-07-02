//
//  VRootViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

@class VSessionTimer;
@protocol Scaffold;

NS_ASSUME_NONNULL_BEGIN

/**
 *  ViewControllers that will be contained by the rootViewController can conform 
 *  to this protocol to be notified about events.
 */
@protocol VRootViewControllerContainedViewController <NSObject>

/**
 *  Informs the contained viewController that the loading animation has finished.
 */
- (void)onLoadingCompletion;

@end

/**
 Posted at the same time as UIApplicationDidBecomeActiveNotification, but
 only if a new session is NOT starting.
 */
extern NSString * const VApplicationDidBecomeActiveNotification;

@interface VRootViewController : UIViewController

/**
 The view controller that is currently being displayed
 */
@property (nonatomic, strong, readonly) UIViewController *currentViewController;

/**
 A session timer that monitors start/stop events and computes duration.
 */
@property (nonatomic, strong, readonly) VSessionTimer *sessionTimer;

@property (nonatomic, strong, readonly) UIViewController<Scaffold> *scaffold;

/**
 Returns the instance of VRootViewController that is set as the main 
 window's rootViewController property. If no such instance exists,
 returns nil.
 */
+ (nullable VRootViewController *)sharedRootViewController;

/**
 Please call this method from UIApplicationDelegate's method of the same name.
 */
- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 Please call this method from UIApplicationDelegate's method of the same name.
 */
- (void)applicationOpenURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;

/**
 Handles local (user) notifications received by the application.  Designed to be called or forwarded
 from the app delegate where the notificaitons are received.
 */
- (void)handleLocalNotification:(UILocalNotification *)localNotification;

/**
 Restarts the session of the app, returning it to a state as if it had just been launched.
 */
- (void)startNewSession;

- (void)presentForceUpgradeScreen;

@end

NS_ASSUME_NONNULL_END
