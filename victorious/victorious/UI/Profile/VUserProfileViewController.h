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

@interface VUserProfileViewController : VStreamCollectionViewController

@property (nonatomic, readonly) VUser *profile;

/**
 *  While this property is YES, the viewController will listen for
 *  login status changes and reload itself with the main user. Will also
 *  display a "logged out" version of its UI.
 */
@property (nonatomic, assign) BOOL representsMainUser;

/**
 Are you sure this is the method you want to use? In almost every case, you should
 use the -userProfileViewControllerWithUser: category on VDependencyManager.
 */
+ (instancetype)userProfileWithUser:(VUser *)aUser andDependencyManager:(VDependencyManager *)dependencyManager;

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