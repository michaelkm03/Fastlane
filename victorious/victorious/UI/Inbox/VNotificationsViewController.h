//
//  VNotificationsViewController.h
//  victorious
//
//  Created by Edward Arenberg on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"
#import "VMultipleContainerChild.h"
#import "VProvidesNavigationMenuItemBadge.h"

@class VUnreadMessageCountCoordinator, VUser, VDependencyManager;

@interface VNotificationsViewController : VFetchedResultsTableViewController <VMultipleContainerChild, VProvidesNavigationMenuItemBadge>

@property (nonatomic, weak) id<VMultipleContainerChildDelegate> multipleViewControllerChildDelegate;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
