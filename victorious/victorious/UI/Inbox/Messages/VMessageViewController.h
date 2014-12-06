//
//  VMessageViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VMessageTableDataSource, VUnreadMessageCountCoordinator, VUser;

@interface VMessageViewController : UITableViewController

@property (nonatomic, strong) VUser *otherUser; ///< The user with whom the logged-in user is conversing
@property (nonatomic, strong, readonly) VMessageTableDataSource *tableDataSource;
@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;

/**
 If YES, the receiver will refresh from the server on -viewWillAppear.
 Resets back to NO on every appearance.
 */
@property (nonatomic) BOOL shouldRefreshOnAppearance;

@end
