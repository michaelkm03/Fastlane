 //
//  VPushNotificationManager.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+VStringWithData.h"
#import "VPushNotificationManager.h"
#import "VConstants.h"

#import "victorious-Swift.h"

static NSString * kPushNotificationTokenDefaultsKey = @"com.getvictorious.PushNotificationTokenDefaultsKey";

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
    NSData *storedToken = [userDefaults dataForKey:kPushNotificationTokenDefaultsKey];
    return storedToken;
}

// Returns false if we already have that token stored.
- (BOOL)storeNewToken:(NSData *)token
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *storedToken = [userDefaults dataForKey:kPushNotificationTokenDefaultsKey];
    
    if ( ![storedToken isEqualToData:token] )
    {
        [userDefaults setObject:token forKey:kPushNotificationTokenDefaultsKey];
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
    if ( [self storeNewToken:deviceToken] )
    {
        [self sendTokenWithSuccessBlock:nil failBlock:nil];
    }
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
    
    NSString *pushNotificationID = [NSString v_stringWithData:storedToken];
    RegisterPushNotificationOperation *operation = [[RegisterPushNotificationOperation alloc] initWithPushNotificationID:pushNotificationID];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
    {
        if (error == nil)
        {
            if (success != nil)
            {
                success();
            }
        }
        else if (failure != nil)
        {
            failure(error);
        }
    }];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    VLog(@"Error registering for push notifications: %@", [error localizedDescription]);
}

- (BOOL)isRegisteredForPushNotifications
{
    UIApplication *app = [UIApplication sharedApplication];
    
    return app.currentUserNotificationSettings.types != UIUserNotificationTypeNone;
}

@end
