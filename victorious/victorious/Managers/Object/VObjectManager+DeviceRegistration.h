//
//  VObjectManager+DeviceRegistration.h
//  victorious
//
//  Created by Josh Hinman on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager (DeviceRegistration)

- (RKManagedObjectRequestOperation *)registerAPNSToken:(NSData *)apnsToken
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)getDevicePreferencesSuccessBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)setDevicePreferences:(NSDictionary *)dictionary
                                             SuccessBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)failed;

@end
