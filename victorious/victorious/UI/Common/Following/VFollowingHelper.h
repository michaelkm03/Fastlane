//
//  VFollowingHelper.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const VFollowSourceScreenDiscover;
extern NSString * const VFollowSourceScreenReposter;
extern NSString * const VFollowSourceScreenProfile;
extern NSString * const VFollowSourceScreenUserSearchResults;
extern NSString * const VFollowSourceScreenFollowersList;
extern NSString * const VFollowSourceScreenFollowingList;
extern NSString * const VFollowSourceScreenLikersList;
extern NSString * const VFollowSourceScreenMessageableUsersList;
extern NSString * const VFollowSourceScreenFindFriendsContacts;
extern NSString * const VFollowSourceScreenFindFriendsFacebook;
extern NSString * const VFollowSourceScreenFindFriendsTwitter;
extern NSString * const VFollowSourceScreenShelf;
// Untracked is used when a screen performs 'follow' action
// through the responder chain unexpectedly. Instead of sending nil,
// send this so we can track them down later
extern NSString * const VFollowSourceUntracked;

@class VDependencyManager;
@class VUser;

/**
 *  VFollowCommandCompletion blocks are executed after a command has completed.
 *
 *  @param userActedOn the user that this command was initially executed with
 */
typedef void (^VFollowHelperCompletion)(VUser *userActedOn);

/**
 *  VFollowerCommandHandler executes requests from the responder chain to follow a particular user.
 */
@interface VFollowingHelper : NSObject

/**
 *  Designated intializers for the class. Both parameters are required.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
                viewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Will present authorization on this viewController must not be nil 
 *  by the time VFollowerCommandHandler receives VFollowCommands.
 */
@property (nonatomic, weak, readonly) UIViewController *viewControllerToPresentAuthorizationOn;

/**
 *  Required for authorization. 
 *
 *  Temporary until authorization is incorporated to the command system.
 */
@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

/**
 * Follows the user passed in after any authorization.
 */
- (void)followUser:(VUser *)user
withAuthorizedBlock:(void (^)(void))authorizedBlock
    andCompletion:(VFollowHelperCompletion)completion
        fromScreen:(NSString *)screenName;

/**
 * Follows the user passed in after any authorization.
 */
- (void)unfollowUser:(VUser *)user
 withAuthorizedBlock:(void (^)(void))authorizedBlock
      andCompletion:(VFollowHelperCompletion)completion;

@end
