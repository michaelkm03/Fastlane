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

@end
