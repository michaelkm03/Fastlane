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


@end
