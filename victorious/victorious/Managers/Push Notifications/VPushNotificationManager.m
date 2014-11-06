//
//  VPushNotificationManager.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+DeviceRegistration.h"
#import "VObjectManager+Login.h"
#import "VPushNotificationManager.h"

@interface VPushNotificationManager ()

@property (nonatomic, strong) NSData *apnsToken;

@end

@implementation VPushNotificationManager

+ (VPushNotificationManager *)sharedPushNotificationManager
{
    static dispatch_once_t onceToken;
    static VPushNotificationManager *sharedPushNotificationManager;
    dispatch_once(&onceToken, ^(void)
    {
        sharedPushNotificationManager = [[VPushNotificationManager alloc] init];
    });
    return sharedPushNotificationManager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startPushNotificationManager
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.apnsToken = deviceToken;
    [self sendAPNStokenToServer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    VLog(@"Error registering for push notifications: %@", [error localizedDescription]);
}

- (void)sendAPNStokenToServer
{
    [[VObjectManager sharedManager] registerAPNSToken:self.apnsToken successBlock:nil failBlock:nil];
}

- (void)loggedInChanged:(NSNotification *)notification
{
    if ([[VObjectManager sharedManager] mainUser])
    {
        [self sendAPNStokenToServer];
    }
}

@end
