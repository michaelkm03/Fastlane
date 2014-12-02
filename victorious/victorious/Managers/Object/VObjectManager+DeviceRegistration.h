//
//  VObjectManager+DeviceRegistration.h
//  victorious
//
//  Created by Josh Hinman on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VNotificationSettings;

@interface VObjectManager (DeviceRegistration)

- (RKManagedObjectRequestOperation *)registerAPNSToken:(NSData *)apnsToken
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)getDeviceSettingsSuccessBlock:(VSuccessBlock)success
                                                         failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)setDeviceSettings:(VNotificationSettings *)settings
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)failed;

@end
