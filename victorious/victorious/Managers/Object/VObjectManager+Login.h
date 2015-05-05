//
//  VObjectManager+Login.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"
#import "VLoginType.h"

@class VDependencyManager;

extern NSString * const kLoggedInChangedNotification;

@interface VObjectManager (Login)

@property (nonatomic, readonly) BOOL mainUserProfileComplete; ///< Has the main user completed their profile according to the `status` field

@property (nonatomic, readonly) BOOL mainUserLoggedIn; ///< Is there a main user that is currently logged in

@property (nonatomic, readonly) BOOL authorized; ///< Is there a currently logged in user and is his or her profile complete

@property (nonatomic, readonly) BOOL mainUserLoggedInWithSocial; ///< Did the currently logged in user connect with Facebook or Twitter

/**
 Retrieves the template from the server
 
 @param dependencyManager A dependency manager containing defaults for any keys not provided by the server
 */
- (RKManagedObjectRequestOperation *)templateWithSuccessBlock:(VSuccessBlock)success
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

/**
 Performs a logout with the server by calling the logout endpoint.
 This should only be called if the request is expected to succeed, i.e. the user
 is currently authorized, as in the case when the user manually logs out.
 */
- (RKManagedObjectRequestOperation *)logout;

/**
 Updates internals the reflect a logged out state.  Also called interally by `logout` method.
 Call this when you want to set the app in a logged out state by do not want to send
 a request to the logout endpoint.
 */
- (void)logoutLocally;

- (RKManagedObjectRequestOperation *)requestPasswordResetForEmail:(NSString *)email
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)resetPasswordWithUserToken:(NSString *)userToken
                                                    deviceToken:(NSString *)deviceToken
                                                    newPassword:(NSString *)newPassword
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail;

- (BOOL)loginWithExistingToken;

@end
