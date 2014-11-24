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

- (RKManagedObjectRequestOperation *)getDevicePreferencesSuccessBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)failed
{
    return [self GET:@"/api/device/preferences"
               object:nil
           parameters:nil
         successBlock:success
            failBlock:failed];
}

- (RKManagedObjectRequestOperation *)setDevicePreferences:(NSDictionary *)dictionary
                                             SuccessBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)failed
{
    return [self POST:@"/api/device/preferences"
               object:nil
           parameters:nil
         successBlock:success
            failBlock:failed];
}

@end
