//
//  VObjectManager+DeviceRegistration.m
//  victorious
//
//  Created by Josh Hinman on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+DeviceRegistration.h"
#import "VObjectManager+Private.h"
#import "VObjectManager+Login.h"
#import "VConstants.h"

@interface VObjectManager()

@property (nonatomic, readonly) NSError *userNotLoggedInError;

@end

@implementation VObjectManager (DeviceRegistration)

- (RKManagedObjectRequestOperation *)getDeviceSettingsSuccessBlock:(VSuccessBlock)success
                                                         failBlock:(VFailBlock)failed
{
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
    return [self POST:@"/api/device/preferences"
               object:nil
           parameters:settings.parametersDictionary
         successBlock:success
            failBlock:failed];
}

- (NSError *)userNotLoggedInError
{
    return [NSError errorWithDomain:@"A user must be logged in to call this end point."
                               code:kErrorCodeDeviceUserNotLoggedIn userInfo:nil];
}

@end
