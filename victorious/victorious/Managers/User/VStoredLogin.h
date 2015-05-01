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
 @return A valid user that can be set to the main user or nil if the operation failed.
 
 */
- (VUser *)lastLoggedInUserFromDisk;

/**
 Save only releveant data necessary to disk in order to to log in at a later time
 without having to contact the server.
 
 @see userFromDisk
 
 @param user The currently-logged in user to save.
 @return Whether or not the write to disk operation was successful.
 */
- (BOOL)saveLoggedInUserToDisk:(VUser *)user;

/**
 Removes any data stored on the device about the last logged in user.  This is
 should be called anytime the user is logged out.
 */
- (BOOL)clearLoggedInUserFromDisk;

@end
