//
//  VFollowResponder.m
//  victorious
//
//  Created by Sharif Ahmed on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VFollowResponder.h"

NSString * const VFollowSourceScreenDiscoverSuggestedUsers = @"discover.suggest";
NSString * const VFollowSourceScreenReposter = @"reposter";
NSString * const VFollowSourceScreenProfile = @"profile";
NSString * const VFollowSourceScreenDiscoverUserSearchResults = @"discover.search";
NSString * const VFollowSourceScreenFollowers = @"followers";
NSString * const VFollowSourceScreenFollowing = @"following";
NSString * const VFollowSourceScreenLikers = @"likers";
NSString * const VFollowSourceScreenMessageableUsers = @"messageable_users";
NSString * const VFollowSourceScreenFindFriendsContacts = @"find_friends.contacts";
NSString * const VFollowSourceScreenFindFriendsFacebook = @"find_friends.facebook";
NSString * const VFollowSourceScreenFindFriendsTwitter = @"find_friends.twitter";
NSString * const VFollowSourceScreenStream = @"stream";
NSString * const VFollowSourceScreenTrendingUserShelf = @"trending_user";
NSString * const VFollowSourceScreenRecommendedUserShelf = @"recommended_user";
NSString * const VFollowSourceScreenRegistrationSuggestedUsers = @"registration.suggest";
NSString * const VFollowSourceScreenSleekCell = @"sleek_cell";
// Untracked is used when a screen performs 'follow' action
// through the responder chain unexpectedly. Instead of sending nil,
// send this so we can track them down later
NSString * const VFollowSourceScreenUnknown = @"unknown";