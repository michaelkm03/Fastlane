//
//  VTwitterManager.h
//  victorious
//
//  Created by Will Long on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPermission.h"

/**
 *  Describes the completion block of the refreshTwitterTokenWithIdentifier:fromViewController:completionBlock:.
 *
 *  @param success Whether or not the twitter authorization was successful.
 *  @param error The error returned from the api call.
 */
typedef void (^VTWitterCompletionBlock) (BOOL success, NSError *error);

/**
 *  Error domain for all non-Twitter-API errors
 */
extern NSString * const VTwitterManagerErrorDomain;

/**
 *  Error code representing that the user canceled the share.
 *  The Twitter acounts manager already shows an alert in these cases.
 */
extern CGFloat const VTwitterManagerErrorCanceled;

/**
 *  Error code representing that we failed to get the user's access token.
 *  The Twitter acounts manager DOES NOT show an alert in these cases.
 */
extern CGFloat const VTwitterManagerErrorFailed;

@interface VTwitterManager : NSObject

@property (nonatomic, readonly) NSString *oauthToken;
@property (nonatomic, readonly) NSString *secret;
@property (nonatomic, readonly) NSString *twitterId;
@property (nonatomic, readonly) NSString *identifier;

+ (VTwitterManager *)sharedManager;

/**
 *  Returns YES when the oauth token, secret, and twitterId are valid.
 */
@property (nonatomic, readonly) BOOL authorizedToShare;

/**
 *  Does a twitter reverse oauth and stores the information in the class properties
 *
 *  @param identifier      The identifier for the account to use.  May be nil.
 *  @param completionBlock Block that will run after completing.
 */
- (void)refreshTwitterTokenFromViewController:(UIViewController *)viewController
                          completionBlock:(VTWitterCompletionBlock)completionBlock;

@end
