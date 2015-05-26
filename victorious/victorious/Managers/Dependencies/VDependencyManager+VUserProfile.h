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
extern NSString * const VDependencyManagerProfileEditButtonStyleKey;
extern NSString * const VDependencyManagerProfileEditButtonStylePill;

@interface VDependencyManager (VUserProfile)

/**
 Returns a new VUserProfileViewController instance according to the
 template configuration, primed to display the given user.
 */
- (VUserProfileViewController *)userProfileViewControllerWithUser:(VUser *)user;

/**
 Returns a new VUserProfileViewController instance according to the
 template configuration, primed to display the user with the given remoteID.
 */
- (VUserProfileViewController *)userProfileViewControllerWithRemoteId:(NSNumber *)remoteId;

/**
 Returns a new template implementation of VUserProfileHeader primed to display the given user.
 */
- (UIViewController<VUserProfileHeader> *)userProfileHeaderWithUser:(VUser *)user;

@end