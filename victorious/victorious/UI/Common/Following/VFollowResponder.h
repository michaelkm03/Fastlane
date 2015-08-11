//
//  VFollowResponder.h
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
typedef void (^VFollowEventCompletion)(VUser *userActedOn);

static NSString * const VFollowSourceScreenDiscoverSuggestedUsers = @"discover.suggest";
static NSString * const VFollowSourceScreenReposter = @"reposter";
static NSString * const VFollowSourceScreenProfile = @"profile";
static NSString * const VFollowSourceScreenDiscoverUserSearchResults = @"discover.search";
static NSString * const VFollowSourceScreenFollowers = @"followers";
static NSString * const VFollowSourceScreenFollowing = @"following";
static NSString * const VFollowSourceScreenLikers = @"likers";
static NSString * const VFollowSourceScreenMessageableUsers = @"messageable_users";
static NSString * const VFollowSourceScreenFindFriendsContacts = @"find_friends.contacts";
static NSString * const VFollowSourceScreenFindFriendsFacebook = @"find_friends.facebook";
static NSString * const VFollowSourceScreenFindFriendsTwitter = @"find_friends.twitter";
static NSString * const VFollowSourceScreenShelf = @"shelf";
static NSString * const VFollowSourceScreenRegistrationSuggestedUsers = @"registration.suggest";
// Untracked is used when a screen performs 'follow' action
// through the responder chain unexpectedly. Instead of sending nil,
// send this so we can track them down later
static NSString * const VFollowSourceScreenUnknown = @"unknown";

@protocol VFollowResponder <NSObject>

/**
 *  A command for the current user to follow a specific user.
 *
 *  @param user The user
 *  @param completion Required completion block.
 */
- (void)followUser:(VUser *)user
withAuthorizedBlock:(void (^)(void))authorizedBlock
     andCompletion:(VFollowEventCompletion)completion
fromViewController:(UIViewController *)viewControllerToPresentOn
    withScreenName:(NSString *)screenName;

/**
 *  A command for the current user to unfollow a specific user.
 *
 *  @param user The user
 *  @param completion Required completion block.
 */
- (void)unfollowUser:(VUser *)user
 withAuthorizedBlock:(void (^)(void))authorizedBlock
       andCompletion:(VFollowEventCompletion)completion;

@end
