//
//  VNotificationsViewController.h
//  victorious
//
//  Created by Edward Arenberg on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VProvidesNavigationMenuItemBadge.h"
#import "VAuthorizationContextProvider.h"
#import "VAccessoryNavigationSource.h"
#import "VNoContentView.h"

@class VUnreadMessageCountCoordinator, VUser, VDependencyManager, NotificationsDataSource;

@interface VNotificationsViewController : UIViewController <VAuthorizationContextProvider, VAccessoryNavigationSource>

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (strong, nonatomic) VNoContentView *noContentView;
@property (strong, nonatomic) NotificationsDataSource *dataSource;
@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
