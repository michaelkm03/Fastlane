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

NSString *const VPushNotificationManagerDidReceiveResponse = @"com.getvictorious.PushNotificationManagerDidRegister";
NSString *const VPushNotificationTokenDefaultsKey = @"com.getvictorious.PushNotificationTokenDefaultsKey";

@interface VPushNotificationManager ()

@property (nonatomic, readwrite) BOOL started;

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
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    self.started = YES;
}

- (NSData *)storedToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *storedToken = [userDefaults dataForKey:VPushNotificationTokenDefaultsKey];
    return storedToken;
}

// Returns false if we already have that token stored.
- (BOOL)storeNewToken:(NSData *)token
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *storedToken = [userDefaults dataForKey:VPushNotificationTokenDefaultsKey];
    
    if ( ![storedToken isEqualToData:token] )
    {
        [userDefaults setObject:token forKey:VPushNotificationTokenDefaultsKey];
        [userDefaults synchronize];
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VPushNotificationManagerDidReceiveResponse object:self];

    if ( [self storeNewToken:deviceToken] )
    {
        [self sendTokenWithSuccessBlock:nil failBlock:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
}

- (void)sendTokenWithSuccessBlock:(void(^)())success failBlock:(void(^)(NSError *error))failure
{
    NSData *storedToken = [self storedToken];
    if (storedToken.length == 0)
    {
        NSString *domain = NSLocalizedString( @"ErrorPushNotificationsUnknown", nil );
        
        if ( failure != nil )
        {
            failure( [NSError errorWithDomain:domain code:-1 userInfo:nil] );
        }
        return;
    }

    [[VObjectManager sharedManager] registerAPNSToken:storedToken successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
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
    [[NSNotificationCenter defaultCenter] postNotificationName:VPushNotificationManagerDidReceiveResponse object:self];
    VLog(@"Error registering for push notifications: %@", [error localizedDescription]);
}

- (void)loggedInChanged:(NSNotification *)notification
{
    if ([[VObjectManager sharedManager] mainUserLoggedIn])
    {
        [self sendTokenWithSuccessBlock:nil failBlock:nil];
    }
}

- (BOOL)isRegisteredForPushNotifications
{
    UIApplication *app = [UIApplication sharedApplication];
    
    return app.currentUserNotificationSettings.types != UIUserNotificationTypeNone;
}

@end
