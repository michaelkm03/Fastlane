//
//  VDependencyManager+VUserProfile.h
//  victorious
//
//  Created by Patrick Lynch on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VUser.h"

@class VUserProfileViewController;
@protocol VUserProfileHeader, VUserProfileHeaderDelegate;

extern NSString * const VDependencyManagerUserProfileViewComponentKey;
extern NSString * const VDependencyManagerUserProfileHeaderComponentKey;
extern NSString * const VDependencyManagerUserKey;
extern NSString * const VDependencyManagerUserRemoteIdKey;
extern NSString * const VDependencyManagerFindFriendsIconKey;

@interface VDependencyManager (VUserProfileViewController)

/**
 Returns a new VUserProfileViewController instance according to the
 template configuration, primed to display the given user.
 
 @param user The user whose profile we should display
 @param key  The template key holding the configuration information for VUserProfileViewController
 */
- (VUserProfileViewController *)userProfileViewControllerWithUser:(VUser *)user;

/**
 Returns a new VUserProfileViewController instance according to the
 template configuration, primed to display the user with the given remoteID.
 
 @param user The user whose profile we should display
 @param key  The template key holding the configuration information for VUserProfileViewController
 */
- (VUserProfileViewController *)userProfileViewControllerWithRemoteId:(NSNumber *)remoteId;

- (UIViewController<VUserProfileHeader> *)userProfileHeaderWithUser:(VUser *)user;

@end