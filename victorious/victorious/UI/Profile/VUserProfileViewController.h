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

@property (nonatomic, strong, readwrite) VUser *user;

- (void)toggleFollowUser;

@end
