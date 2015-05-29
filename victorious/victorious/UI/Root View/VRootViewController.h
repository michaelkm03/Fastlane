//
//  VRootViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSideMenuViewController.h"
#import "VDeeplinkReceiver.h"

@class VSessionTimer;

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

/**
 NOT A CONSTRUCTOR/FACTORY METHOD. Returns the instance of VRootViewController that is 
 set as the main window's rootViewController property. If no such instance exists,
 returns nil.
 */
+ (instancetype)rootViewController;

/**
 Please call this method from UIApplicationDelegate's method of the same name.
 */
- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 Please call this method from UIApplicationDelegate's method of the same name.
 */
- (void)applicationOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/**
 Opens a deeplink URL
 */
- (void)openURL:(NSURL *)url;

- (void)presentForceUpgradeScreen;

@end
