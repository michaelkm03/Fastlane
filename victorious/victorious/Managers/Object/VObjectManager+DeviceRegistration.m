//
//  VObjectManager+DeviceRegistration.m
//  victorious
//
//  Created by Josh Hinman on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+VStringWithData.h"
#import "VObjectManager+DeviceRegistration.h"
#import "VObjectManager+Private.h"
#import "VNotificationSettings+RestKit.h"
#import "VObjectManager+Login.h"

@interface VObjectManager()

@property (nonatomic, readonly) NSError *userNotLoggedInError;

@end

@implementation VObjectManager (DeviceRegistration)

- (RKManagedObjectRequestOperation *)registerAPNSToken:(NSData *)apnsToken
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)failed
{
    NSString *apnsString = [NSString v_stringWithData:apnsToken];
    return [self POST:@"/api/device/register_push_id"
               object:nil
           parameters:@{ @"push_id": apnsString }
         successBlock:success
            failBlock:failed];
}

- (RKManagedObjectRequestOperation *)getDeviceSettingsSuccessBlock:(VSuccessBlock)success
                                                         failBlock:(VFailBlock)failed
{
    if ( ! self.mainUserLoggedIn )
    {
        failed( nil, self.userNotLoggedInError );
        return nil;
    }
    
    return [self GET:@"/api/device/preferences"
               object:nil
           parameters:nil
         successBlock:success
            failBlock:failed];
}

- (RKManagedObjectRequestOperation *)setDeviceSettings:(VNotificationSettings *)settings
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)failed
{
    if ( ! self.mainUserLoggedIn )
    {
        failed( nil, self.userNotLoggedInError );
        return nil;
    }
    
    return [self POST:@"/api/device/preferences"
               object:nil
           parameters:settings.parametersDictionary
         successBlock:success
            failBlock:failed];
}

- (NSError *)userNotLoggedInError
{
    return [NSError errorWithDomain:@"A user must be logged in to call this end point." code:-1 userInfo:nil];
}

@end
