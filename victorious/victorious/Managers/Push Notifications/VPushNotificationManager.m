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

@property (nonatomic, strong) NSData *apnsToken;
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

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VPushNotificationManagerDidReceiveResponse object:self];

    self.apnsToken = deviceToken;
    [self sendTokenWithSuccessBlock:nil failBlock:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
}

- (void)sendTokenWithSuccessBlock:(void(^)())success failBlock:(void(^)(NSError *error))failure
{
    // If, for whatever reason, we still do not have the token or if it's empty, the user is unforunately out of luck:
    if ( self.apnsToken.length == 0 )
    {
        NSString *domain = NSLocalizedString( @"ErrorPushNotificationsUnknown", nil );
        
        if ( failure != nil )
        {
            failure( [NSError errorWithDomain:domain code:-1 userInfo:nil] );
        }
        return;
    }

    // Comparing the stored token with the new one, if no token is stored or if it has changes, the compare will fail and new token will be stored locally and on the server instead.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *storedToken = [userDefaults dataForKey:VPushNotificationTokenDefaultsKey];
    
    if ( [storedToken isEqualToData:self.apnsToken] )
    {
        // Silently exit scope, since token is already stored locally and on server.
        return;
    }
    
    // If we've got a new token, send it to the server and if we succeed we store it locally:
    [[VObjectManager sharedManager] registerAPNSToken:self.apnsToken successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults setObject:self.apnsToken forKey:VPushNotificationTokenDefaultsKey];
         [userDefaults synchronize];
         
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
