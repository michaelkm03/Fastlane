//
//  VFollowResponder.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

NS_ASSUME_NONNULL_BEGIN

/**
 *  VFollowCommandCompletion blocks are executed after a command has completed.
 *
 *  @param userActedOn the user that this command was initially executed with
 */
typedef void (^VFollowEventCompletion)(VUser *userActedOn);

extern NSString * const VFollowSourceScreenDiscoverSuggestedUsers;
extern NSString * const VFollowSourceScreenReposter;
extern NSString * const VFollowSourceScreenProfile;
extern NSString * const VFollowSourceScreenDiscoverUserSearchResults;
extern NSString * const VFollowSourceScreenFollowers;
extern NSString * const VFollowSourceScreenFollowing;
extern NSString * const VFollowSourceScreenLikers;
extern NSString * const VFollowSourceScreenMessageableUsers;
extern NSString * const VFollowSourceScreenFindFriendsContacts;
extern NSString * const VFollowSourceScreenFindFriendsFacebook;
extern NSString * const VFollowSourceScreenStream;
extern NSString * const VFollowSourceScreenTrendingUserShelf;
extern NSString * const VFollowSourceScreenRecommendedUserShelf;
extern NSString * const VFollowSourceScreenRegistrationSuggestedUsers;
extern NSString * const VFollowSourceScreenSleekCell;
// Untracked is used when a screen performs 'follow' action
// through the responder chain unexpectedly. Instead of sending nil,
// send this so we can track them down later
extern NSString * const VFollowSourceScreenUnknown;

@protocol VFollowResponder <NSObject>

/**
 *  A command for the current user to follow a specific user.
 *
 *  @param user The user
 *  @param authorizedBlock Authroized block to be performed after authroization(if necessary)
 *  @param completion Required completion block.
 *  @param viewControllerToPresentOn The viewController to present the authorization action on
 *  @param screenName The sourceScreenName of source view controller
 */
- (void)followUser:(VUser *)user
withAuthorizedBlock:(void (^ __nullable)(void))authorizedBlock
     andCompletion:(VFollowEventCompletion)completion
fromViewController:(UIViewController * __nullable)viewControllerToPresentOn
    withScreenName:(NSString * __nullable)screenName;

/**
 *  A command for the current user to unfollow a specific user.
 *
 *  @param user The user
 *  @param authorizedBlock Authroized block to be performed after authroization(if necessary)
 *  @param completion Required completion block.
 *  @param viewControllerToPresentOn The viewController to present the authorization action on
 *  @param screenName The sourceScreenName of source view controller
 */
- (void)unfollowUser:(VUser *)user
 withAuthorizedBlock:(void (^ __nullable)(void))authorizedBlock
       andCompletion:(VFollowEventCompletion)completion
  fromViewController:(UIViewController * __nullable)viewControllerToPresentOn
       withScreenName:(NSString * __nullable)screenName;

@end

NS_ASSUME_NONNULL_END
