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
@property (nonatomic, readonly, strong) VDependencyManager *dependencyManager;

/**
 *  Designated initializer for the class.
 *
 *  @param viewController Will present any needed viewControllers on this viewController.
 *  @param dependencyManager The dependency manager to use for styling.
 */
- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewController
                                dependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  The user has entered the passed in username and requested update.
 */
- (void)setUsername:(NSString *)username
        displayName:(NSString *)displayName
         completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  The user has forgot their password and would like a reset.
 */
- (void)forgotPasswordWithStartingEmail:(NSString *)startingEmail
                             completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  The user has entered their reset token and is requesting verificaiton.
 */
- (void)setResetToken:(NSString *)resetToken
           completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  The user wants to change their password to the given password.
 */
- (void)updatePassword:(NSString *)password
            completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  The user has taken a profile picture send it to the backend.
 */
- (void)updateProfilePictureWithPictureAtFilePath:(NSURL *)filePath
                                       completion:(void (^)(BOOL success, NSError *error))completion;

@end
