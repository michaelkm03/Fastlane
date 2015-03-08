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

@property   (nonatomic, readonly) VUser                  *profile;

+ (instancetype)userProfileWithRemoteId:(NSNumber *)remoteId;
+ (instancetype)userProfileWithUser:(VUser *)aUser;

@end

#pragma mark -

@interface VDependencyManager (VUserProfileViewControllerAdditions)

/**
 Returns a new VUserProfileViewController instance according to the 
 template configuration, primed to display the given user.
 
 @param user The user whose profile we should display
 @param key  The template key holding the configuration information for VUserProfileViewController
 */
- (VUserProfileViewController *)userProfileViewControllerWithUser:(VUser *)user forKey:(NSString *)key;

- (VUserProfileViewController *)mainUserProfileViewController;

@end