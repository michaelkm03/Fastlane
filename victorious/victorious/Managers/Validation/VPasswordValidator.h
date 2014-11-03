//
//  VPasswordValidator.h
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VValidator.h"

extern NSInteger const VErrorCodeCurrentPasswordIsInvalid;
extern NSInteger const VErrorCodeInvalidPasswordEntered;
extern NSInteger const VErrorCodeInvalidPasswordsDoNotMatch;
extern NSInteger const VErrorCodeInvalidPasswordsNewEqualsCurrent;

@interface VPasswordValidator : VValidator

/**
 Validates a password for basic password requirements.
 */
- (BOOL)validatePassword:(NSString *)password error:(NSError **)outError;

/**
 Validates basic password requirements as well as matching to a confirmation password.
 */
- (BOOL)validatePassword:(NSString *)password withConfirmation:(NSString *)confirmationPassword error:(NSError **)outError;

/**
 Validates basic password requirements when resetting to a new password, including basic validation, matching to a confirmation password, and checking to make sure the current password is not the same as the new one.
 */
- (BOOL)validateCurrentPassword:(NSString *)currentPassword withNewPassword:(NSString *)newPassword withConfirmation:(NSString *)confirmationPassword error:(NSError **)outError;

@end
