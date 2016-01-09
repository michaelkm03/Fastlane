//
//  VFollowResponder.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

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
