//
//  VObjectManager+Login.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

extern NSString *kLoggedInChangedNotification;

@interface VObjectManager (Login)

@property (nonatomic, readonly, getter = isAuthorized)  BOOL    authorized;
@property (nonatomic, readonly, getter = isOwner)       BOOL    owner;

- (RKManagedObjectRequestOperation *)loginToFacebookWithToken:(NSString*)accessToken
                                                 SuccessBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)loginToTwitterWithToken:(NSString*)accessToken
                                                SuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email
                                                       password:(NSString *)password
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)createVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)updateVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail;
 
- (RKManagedObjectRequestOperation *)logout;

@end
