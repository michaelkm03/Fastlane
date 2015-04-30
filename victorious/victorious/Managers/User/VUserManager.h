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
- (void)loginViaFacebookOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock;

/**
 Make sure we have access to the user's Twitter accounts before calling this
 */
- (void)loginViaTwitterOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock;

- (void)loginViaTwitterWithTwitterID:(NSString *)twitterID
                        OnCompletion:(VUserManagerLoginCompletionBlock)completion
                             onError:(VUserManagerLoginErrorBlock)errorBlock;

- (void)createEmailAccount:(NSString *)email password:(NSString *)password userName:(NSString *)userName onCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock;

- (void)loginViaEmail:(NSString *)email password:(NSString *)password onCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock;

/**
 Re-login to whatever service the user last logged in with
 */
- (void)loginViaSavedCredentialsOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock;

- (void)logout;

/**
 Saves the user's password in the keychain for automatic login in the future
 */
- (BOOL)savePassword:(NSString *)password forEmail:(NSString *)email;

/**
 Retrives an abbreviated user object read from disk that can be used to log in
 (i.e. to set current, authorized user) without having to contact the server.
 
 @see saveUserToDisk:
 @return A valid user that can be set to the main user or nil if the operation failed.
 
 */
- (VUser *)loadLastLoggedInUserFromDisk;

/**
 Save only releveant data necessary to disk in order to to log in at a later time
 without having to contact the server.
 
 @see userFromDisk
 
 @param user The currently-logged in user to save.
 @return Whether or not the write to disk operation was successful.
 */
- (BOOL)saveLoggedInUserToDisk:(VUser *)user;

/**
 Removes any data stored on the device about the last logged in user.  This is
 should be called anytime the user is logged out.
 */
- (BOOL)clearLoggedInUserFromDisk;

@end
