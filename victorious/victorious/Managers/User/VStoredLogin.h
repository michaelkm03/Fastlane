//
//  VStoredLogin.h
//  victorious
//
//  Created by Patrick Lynch on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

/**
 A class that manages storing user info to disk so that the application can log
 in quickly after loading without having to contact the server.
 */
@interface VStoredLogin : NSObject

/**
 Retrives an abbreviated user object read from disk that can be used to log in
 (i.e. to set current, authorized user) without having to contact the server.
 
 @see saveUserToDisk:
 
 @return A valid user that can be set to the main user.  Returns nil if there is
 isn't any last logged in user or if the authorization data of the last
 logged in user is invalid.
 */
- (VUser *)lastLoggedInUserFromDisk;

/**
 Save an abbreviated user object to disk to be retreived later when logging in
 during app load.
 
 @see userFromDisk
 
 @param user The currently logged in user to save.
 @return Whether or not the write operation was successful.
 */
- (BOOL)saveLoggedInUserToDisk:(VUser *)user;

/**
 Removes any data stored on the device about the last logged in user.  This
 should be called anytime the user is logged out.
 */
- (BOOL)clearLoggedInUserFromDisk;

@end
