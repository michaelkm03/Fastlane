//
//  VStoredPassword.h
//  victorious
//
//  Created by Josh Hinman on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A class that manages storing user passwords to the keychain
 */
@interface VStoredPassword : NSObject

/**
 Saves the user's password in the keychain for automatic login in the future
 */
- (BOOL)savePassword:(NSString *)password forUsername:(NSString *)username;

/**
 Returns a previously-stored password
 */
- (nullable NSString *)passwordForUsername:(NSString *)username;

/**
 Removes a previously-stored password from the keychain
 */
- (BOOL)clearSavedPassword;

@end

NS_ASSUME_NONNULL_END
