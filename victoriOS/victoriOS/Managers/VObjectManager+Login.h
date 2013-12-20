//
//  VObjectManager+Login.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

extern NSString *LoggedInNotification;

@interface VObjectManager (Login)

@property (nonatomic, readonly, getter = isAuthorized)  BOOL    authorized;
@property (nonatomic, readonly, getter = isOwner)       BOOL    owner;
@property (nonatomic, readonly, getter = mainUser)      VUser*  mainUser;

- (RKManagedObjectRequestOperation *)loginToFacebookWithToken:(NSString*)accessToken
                                                 SuccessBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)failed;

- (RKManagedObjectRequestOperation *)loginToTwitterWithToken:(NSString*)accessToken
                                                SuccessBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)failed;

- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email
                                                       password:(NSString *)password
                                                   successBlock:(SuccessBlock)success
                                                      failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)createVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(SuccessBlock)success
                                                     failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)updateVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(SuccessBlock)success
                                                     failBlock:(FailBlock)fail;

//- (RKManagedObjectRequestOperation *)logOutWithSuccessBlock:(SuccessBlock)success
//                                                  failBlock:(FailBlock)failed;
- (RKManagedObjectRequestOperation *)logout;

@end
