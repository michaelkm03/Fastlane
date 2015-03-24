//
//  VNotificationsViewController.h
//  victorious
//
//  Created by Edward Arenberg on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"

@class VUnreadMessageCountCoordinator, VUser, VDependencyManager;

@interface VNotificationsViewController : VFetchedResultsTableViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
