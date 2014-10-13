//
//  VFriendsManager.h
//  victorious
//
//  Created by Lawrence Leach on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VObjectManager.h"

@class VUser;

@interface VFriendsManager : NSObject

/**
 Instance of the Friend Manager
 
 @return An instance of the VFriendsManager class
 */
+ (VFriendsManager *)sharedFriendsManager;

/**
 Makes the backend call to follow a user
 
 @param user         User to be followed
 @param successBlock Code block to be executed if api call succeeds
 @param failureBlock Code block to be executed if api call fails
 */
- (void)followUser:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failedBlock;

/**
 Makes the backend api call to unfollow a user
 
 @param user         User to be unfollowed
 @param successBlock Code block to be executed if api call succeeds
 @param failureBlock Code block to be executed if api call fails
 */
- (void)unfollowUser:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failedBlock;

/**
 Submit a batch of users to be followed to the backend api 
 
 @param followers    NSArray of VUser objects
 @param successBlock Code block to be executed if api call succeeds
 @param failureBlock Code block to be executed if api call fails
 */
- (void)followBatchOfUsers:(NSArray *)followers withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failureBlock;

/**
 Checks if a relationship exists between a user and the mainUser objects
 */
- (BOOL)isFollowingUser:(VUser *)targetUser;

@end
