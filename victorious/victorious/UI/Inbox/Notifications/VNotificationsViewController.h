//
//  VNotificationsViewController.h
//  victorious
//
//  Created by Edward Arenberg on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"
#import "VMultipleContainer.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "VAuthorizationContextProvider.h"
#import "VAccessoryNavigationSource.h"

@class VUnreadMessageCountCoordinator, VUser, VDependencyManager;

@interface VNotificationsViewController : VFetchedResultsTableViewController <VMultipleContainerChild, VProvidesNavigationMenuItemBadge, VAuthorizationContextProvider, VAccessoryNavigationSource>

@property (nonatomic, weak) id<VMultipleContainerChildDelegate> multipleContainerChildDelegate;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
