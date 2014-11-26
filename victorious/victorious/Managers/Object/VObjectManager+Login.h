//
//  VObjectManager+Login.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

extern NSString * const kLoggedInChangedNotification;
extern NSString * const kInitResponseNotification;

@interface VObjectManager (Login)

@property (nonatomic, readonly) BOOL mainUserProfileComplete;
@property (nonatomic, readonly) BOOL mainUserLoggedIn;
@property (nonatomic, readonly) BOOL authorized;


- (RKManagedObjectRequestOperation *)appInitWithSuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)loginToFacebookWithToken:(NSString *)accessToken
                                                 SuccessBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)createFacebookWithToken:(NSString *)accessToken
                                                SuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)loginToTwitterWithToken:(NSString *)accessToken
                                                accessSecret:(NSString *)accessSecret
                                                   twitterId:(NSString *)twitterId
                                                SuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed;

- (RKManagedObjectRequestOperation *)createTwitterWithToken:(NSString *)accessToken
                                               accessSecret:(NSString *)accessSecret
                                                  twitterId:(NSString *)twitterId
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

- (AFHTTPRequestOperation *)updateVictoriousWithEmail:(NSString *)email
                                             password:(NSString *)password
                                                 name:(NSString *)name
                                      profileImageURL:(NSURL *)profileImageURL
                                             location:(NSString *)location
                                              tagline:(NSString *)tagline
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail;

- (AFHTTPRequestOperation *)updatePasswordWithCurrentPassword:(NSString *)currentPassword
                                                  newPassword:(NSString *)newPassword
                                                 successBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)logout;

- (RKManagedObjectRequestOperation *)requestPasswordResetForEmail:(NSString *)email
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)resetPasswordWithUserToken:(NSString *)userToken
                                                    deviceToken:(NSString *)deviceToken
                                                    newPassword:(NSString *)newPassword
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail;

@end
