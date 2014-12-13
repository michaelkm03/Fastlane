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
#import "VConstants.h"

NSString * const VPushNotificationManagerDidRegister = @"com.getvictorious.PushNotificationManagerDidRegister";

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

- (void)sendTokenWithSuccessBlock:(void(^)())success failBlock:(void(^)(NSError *error))failure
{
    // If, for whatever reason, we still do not have the token, the user is unforunately out of luck:
    if ( self.apnsToken == nil )
    {
        NSString *domain = NSLocalizedString( @"ErrorPushNotificationsUnknown", nil );
        
        if ( failure != nil )
        {
            failure( [NSError errorWithDomain:domain code:-1 userInfo:nil] );
        }
        return;
    }
    
    // If we've got the token, send it to the server:
    [[VObjectManager sharedManager] registerAPNSToken:self.apnsToken successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         if ( success != nil )
         {
             success();
         }
     }
                                            failBlock:^(NSOperation *operation, NSError *error)
     {
         if ( failure != nil )
         {
             failure( error );
         }
     }];
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
    if ([[VObjectManager sharedManager] mainUserLoggedIn])
    {
        [self sendAPNStokenToServer];
    }
}

- (BOOL)isRegisteredForPushNotifications
{
    UIApplication *app = [UIApplication sharedApplication];
    BOOL isRegistered = NO;
    if ( UI_IS_IOS8_AND_HIGHER )
    {
        isRegistered = app.isRegisteredForRemoteNotifications;
    }
    else
    {
        isRegistered = app.enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
    }
    
    return isRegistered;
}

@end
