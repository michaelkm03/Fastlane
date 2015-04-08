//
//  VNotificationsViewController.h
//  victorious
//
//  Created by Edward Arenberg on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"
#import "VMultipleContainer.h"

@class VUnreadMessageCountCoordinator, VUser, VDependencyManager;

@interface VNotificationsViewController : VFetchedResultsTableViewController <VMultipleContainerChild>

@property (nonatomic, weak) id<VMultipleContainerChildDelegate> multipleContainerChildDelegate;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
