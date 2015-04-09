//
//  VInboxViewController.h
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VDeeplinkHandler.h"
#import "VFetchedResultsTableViewController.h"
#import "VNavigationDestination.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "VMultipleContainerChild.h"

@class VUnreadMessageCountCoordinator, VUser, VDependencyManager;

extern NSString * const VInboxContainerViewControllerDeeplinkHostComponent; ///< The host component for deeplink URLs that point to inbox messages
extern NSString * const VInboxContainerViewControllerInboxPushReceivedNotification; ///< Posted when an inbox push notification is received while the app is active

@interface VInboxViewController : VFetchedResultsTableViewController <VMultipleContainerChild, VProvidesNavigationMenuItemBadge>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) id<VMultipleContainerChildDelegate> multipleViewControllerChildDelegate;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;
- (void)displayConversationForUser:(VUser *)user; ///< Pushes the conversation view for the given user onto the navigation controller
- (IBAction)userSearchAction:(id)sender;

@end
