//
//  VFollowEvent.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

/**
 *  VFollowCommandCompletion blocks are executed after a command has completed.
 *
 *  @param userActedOn the user that this command was initially executed with
 */
typedef void (^VFollowCommandCompletion)(VUser *userActedOn);

@protocol VFollowEvent <NSObject>

/**
 *  A command for the current user to follow a specific user.
 *
 *  @param user The user
 *  @param completion Required completion block.
 */
- (void)followUser:(VUser *)user
    withCompletion:(VFollowCommandCompletion)completion;

/**
 *  A command for the current user to unfollow a specific user.
 *
 *  @param user The user
 *  @param completion Required completion block.
 */
- (void)unfollowUser:(VUser *)user
      withCompletion:(VFollowCommandCompletion)completion;

@end
