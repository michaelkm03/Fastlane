//
//  VUserManager.h
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;

typedef void (^VUserManagerLoginCompletionBlock)(VUser *user, BOOL created);
typedef void (^VUserManagerLoginErrorBlock)(NSError *error);

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
- (void)savePassword:(NSString *)password forEmail:(NSString *)email;

@end
