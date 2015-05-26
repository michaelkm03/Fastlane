//
//  VPushNotificationManager.h
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class registers for push notifications,
 notifies the server of the push token,
 keeps the server updated of login changes.
 */
@interface VPushNotificationManager : NSObject

@property (nonatomic, readonly) BOOL started; ///< YES if -startPushNotificationManager has already been called.

+ (VPushNotificationManager *)sharedPushNotificationManager;

/**
 Register for push notifications and begin monitoring for login changes
 */
- (void)startPushNotificationManager;

/**
 This method should be called from within UIApplicationDelegate's application:didRegisterForRemoteNotificationsWithDeviceToken:
 */
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 This method should be called from within UIApplicationDelegate's application:didFailToRegisterForRemoteNotificationsWithError:
 */
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 This method sends the APNs token to the server.  It is useful in the event that the user allowed push
 notifications but for some reason the APNs token never made it to the server, such as a network error.
 If this request returns successfully, you can assume with relative safety that thes server now has
 the token in the database for the current user.
 */
- (void)sendTokenWithSuccessBlock:(void(^)())success failBlock:(void(^)(NSError *error))failure;

/**
 Uses version-specific methods and properties of UIApplication to check if the device
 is registered (i.e. user gave permissions once before) and is still enabled (i.e. user
 has not manually disabled notifications the device system preferences after having
 given permission once before).
 */
@property (nonatomic, readonly) BOOL isRegisteredForPushNotifications;

@end
