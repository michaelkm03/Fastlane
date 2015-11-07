//
//  VUserManager.h
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;
@class RKManagedObjectRequestOperation;

typedef void (^VTwitterAuthenticationCompletionBlock)(NSString *identifier, NSString *token, NSString *secret, NSString *twitterId);
typedef void (^VUserManagerLoginCompletionBlock)(VUser *user, BOOL isNewUser);
typedef void (^VUserManagerLoginErrorBlock)(NSError *error, BOOL thirdPartyAPIFailure);

@interface VUserManager : NSObject

/**
 Retrieve Twitter oauth data for a certain Twitter account.
 */
- (void)retrieveTwitterTokenWithAccountIdentifier:(NSString *)identifier
                                     onCompletion:(VTwitterAuthenticationCompletionBlock)completion
                                          onError:(VUserManagerLoginErrorBlock)errorBlock;

/**
 Log in using an e-mail address and password
 */
- (RKManagedObjectRequestOperation *)loginViaEmail:(NSString *)email
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

@end
