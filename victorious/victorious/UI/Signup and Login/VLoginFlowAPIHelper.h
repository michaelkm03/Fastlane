//
//  VLoginFlowHelper.h
//  victorious
//
//  Created by Michael Sena on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDependencyManager.h"

/**
 *  VLoginFlowHelper abstracts away much of the common API interactions between login and
 *  registration flows. All completion blocks are required parameters unless otherwise noted.
 *  All completion blocks are called on the main thread.
 */
@interface VLoginFlowAPIHelper : NSObject

/**
 *  Designated initializer for the class.
 *
 *  @param viewController Will present any needed viewControllers on this viewController.
 *  @param dependencyManager The dependency manager to use for styling.
 */
- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewController
                                dependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 *  The user has selected twitter authorization.
 */
- (void)selectedTwitterAuthorizationWithCompletion:(void (^)(BOOL))completion;

/**
 *  The user has entered the passed email nad password and requested login.
 */
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void(^)(BOOL success, NSError *error))completion;

/**
 *  The user has entered the passed in email and password and has requested register.
 */
- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
               completion:(void (^)(BOOL, NSError *))completion;

/**
 *  The user has entered the passed in username and requested update.
 */
- (void)setUsername:(NSString *)username
         completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  The user has forgot their password and would like a reset.
 */
- (void)forgotPasswordWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end
