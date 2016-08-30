//
//  VStoredLogin.h
//  victorious
//
//  Created by Patrick Lynch on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLoginType.h"

@class VUser;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kLoggedInChangedNotification;

@interface VStoredLoginInfo : NSObject

@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong, readonly) NSNumber *userRemoteId;
@property (nonatomic, assign, readonly) VLoginType lastLoginType;

@end

/**
 A class that manages storing user info to disk so that the application can log
 in quickly after loading without having to contact the server.
 */
@interface VStoredLogin : NSObject

/**

 */
- (nullable VStoredLoginInfo *)storedLoginInfo;

/**
 Save an abbreviated user object to disk to be retreived later when logging in
 during app load.
 
 @see userFromDisk
 
 @return Whether or not the write operation was successful.
 */
- (BOOL)saveLoggedInUserToDisk;

/**
 Removes any data stored on the device about the last logged in user.  This
 should be called anytime the user is logged out.
 */
- (BOOL)clearLoggedInUserFromDisk;

@end

NS_ASSUME_NONNULL_END
