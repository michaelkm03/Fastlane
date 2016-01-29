//
//  VUserProfileViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VStreamCollectionViewController.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "VDeepLinkHandler.h"

@class VUser;

@interface VUserProfileViewController : VStreamCollectionViewController <VAccessoryNavigationSource, VProvidesNavigationMenuItemBadge, VTabMenuContainedViewControllerNavigation, VDeeplinkSupporter>

@property (nonatomic, strong) VUser *user;

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

/**
 Allows calling code to trigger the creating of accessory screen bar button items
 for cases when this view controller needs to propagate badge updates from one of its accessory
 screens before it is ready to be displayed.
 */
- (void)updateAccessoryItems;

@end
