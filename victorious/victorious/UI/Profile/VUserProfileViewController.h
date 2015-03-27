//
//  VUserProfileViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VStreamCollectionViewController.h"

@class VUser;

extern NSString * const VUserProfileFindFriendsIconKey;

@interface VUserProfileViewController : VStreamCollectionViewController

@property   (nonatomic, readonly) VUser                  *profile;

//Total hack versions to the 1.9 release out the door... Replace once depedencyManagers have been propogated down to all the
+ (instancetype)rootDependencyProfileWithRemoteId:(NSNumber *)remoteId;
+ (instancetype)rootDependencyProfileWithUser:(VUser *)user;

+ (instancetype)userProfileWithRemoteId:(NSNumber *)remoteId andDependencyManager:(VDependencyManager *)dependencyManager;
+ (instancetype)userProfileWithUser:(VUser *)aUser andDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  While this property is YES, the viewController will listen for
 *  login status changes and reload itself with the main user. Will also
 *  display a "logged out" version of its UI.
 */
@property (nonatomic, assign) BOOL representsMainUser;

@end

#pragma mark -

@interface VDependencyManager (VUserProfileViewControllerAdditions)

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

@end