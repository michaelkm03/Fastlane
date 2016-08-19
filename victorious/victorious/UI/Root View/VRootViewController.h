//
//  VRootViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

@class VSessionTimer, VDependencyManager;
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

@property (nonatomic, strong ,readonly) VDependencyManager *dependencyManager;

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
 Please call this method from UIApplicationDelegate's method of a similar name.
 */
- (void)applicationOpenURL:(NSURL *)url;

/**
 Restarts the session of the app, returning it to a state as if it had just been launched.
 */
- (void)startNewSession;

/**
 Exposed for Swift extension of VRootViewController. 
 Do not call from outside of VRootViewController.
 */
- (void)initializeScaffold;

@end

NS_ASSUME_NONNULL_END
