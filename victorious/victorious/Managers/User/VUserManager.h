//
//  VUserManager.h
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;

typedef void (^VUserManagerLoginCompletionBlock)(VUser *user, BOOL created);
typedef void (^VUserManagerLoginErrorBlock)(NSError *error, BOOL thirdPartyAPIFailure);

@interface VUserManager : NSObject

+ (VUserManager *)sharedInstance;

/**
 Make sure we have access to the user's Facebook accounts before calling this
 */
- (void)loginViaFacebookOnCompletion:(VUserManagerLoginCompletionBlock)completion
                             onError:(VUserManagerLoginErrorBlock)errorBlock;

/**
 Make sure we have access to the user's Facebook accounts before calling this
 
 @param isModern Set to yes for the monder login flow. Will return a status of "complete" on users vs "incomplete".
 */
- (void)loginViaFacebookModern:(BOOL)isModern
                  OnCompletion:(VUserManagerLoginCompletionBlock)completion
                       onError:(VUserManagerLoginErrorBlock)errorBlock;

/**
 Make sure we have access to the user's Twitter accounts before calling this
 */
- (void)loginViaTwitterModern:(BOOL)isModern
                 onCompletion:(VUserManagerLoginCompletionBlock)completion
                      onError:(VUserManagerLoginErrorBlock)errorBlock;

- (void)loginViaTwitterWithTwitterID:(NSString *)twitterID
                            isModern:(BOOL)isModern
                        OnCompletion:(VUserManagerLoginCompletionBlock)completion
                             onError:(VUserManagerLoginErrorBlock)errorBlock;

- (void)createEmailAccount:(NSString *)email
                  password:(NSString *)password
                  userName:(NSString *)userName
              onCompletion:(VUserManagerLoginCompletionBlock)completion
                   onError:(VUserManagerLoginErrorBlock)errorBlock;

- (void)loginViaEmail:(NSString *)email
             password:(NSString *)password
         onCompletion:(VUserManagerLoginCompletionBlock)completion
              onError:(VUserManagerLoginErrorBlock)errorBlock;

/**
 Re-login to whatever service the user last logged in with
 */
- (void)loginViaSavedCredentialsOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock;

/**
 Performs any cleanup necessary after user has logged out through the server (i.e. VObjectManager).
 */
- (void)userDidLogout;

/**
 Saves the user's password in the keychain for automatic login in the future
 */
- (BOOL)savePassword:(NSString *)password forEmail:(NSString *)email;

@end
