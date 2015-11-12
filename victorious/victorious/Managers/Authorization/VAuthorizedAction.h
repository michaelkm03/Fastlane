//
//  VAuthorizedAction.h
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAuthorizationProvider.h"
#import "VAuthorizationContext.h"

@class VObjectManager, VDependencyManager;

NS_ASSUME_NONNULL_BEGIN

typedef void (^VAuthorizedActionCompletion)(BOOL authorized);

// TODO: Delete this class, use AutoShowLoginOperation instead
@interface VAuthorizedAction : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Desginated initializer that provides the requires dependencies in order to present
 and complete the authorizaion process for any attmpted authorized actions.
 */

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
                    dependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 Checks for user authorization (such as logged in and profile complete), and if
 the user is already authorized or if the subsequent authorization flow completes
 successfully, performs the `completion` block.
 
 @param presentingViewController The view controller in which to present the authorization
 provider view controller that will take the user throuhg the login/signup flow.
 @param context An enum value of VAuthorizationContext that determines which messaging will appear
 to the user when the login provider view is shown.
 @param completion A block to be executed if the user is already logged in or after
 the user completes the authorizaiton process (signup, login, etc.)
 
 @return A boolean that indicates whether the user was alreayd authorized and the block
 provided as the `completion:` parameter was synchronously executed, i.e. before control flow
 was returned to calling code.
 */
- (BOOL)performFromViewController:(UIViewController *)presentingViewController
                          context:(VAuthorizationContext)authorizationContext
                       completion:(VAuthorizedActionCompletion)completionActionBlock;

/**
 Provides calling code with a configured loginViewController. Or nil if the user is already logged in.
 
 @param authorizationContext An authorization context appropriate for the current login context.
 @param completion A completionblock for handling the results of logging in.
 
 @return A configured loginViewController. Or nil if the user is already logged in.
 */
- (UIViewController *__nullable)loginViewControllerWithContext:(VAuthorizationContext)authorizationContext
                                                WithCompletion:(VAuthorizedActionCompletion)completion;

@end

NS_ASSUME_NONNULL_END
