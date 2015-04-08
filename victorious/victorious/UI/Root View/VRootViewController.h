//
//  VRootViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSideMenuViewController.h"
#import "VDeeplinkReceiver.h"

@interface VRootViewController : UIViewController

/**
 The view controller that is currently being displayed
 */
@property (nonatomic, strong, readonly) UIViewController *currentViewController;

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

- (void)presentForceUpgradeScreen;

#warning Temporary
@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

/**
 An object that receives deep links and forwads to appropriate handlers
 */
@property (nonatomic, readonly) VDeeplinkReceiver *deeplinkReceiver;

@end
