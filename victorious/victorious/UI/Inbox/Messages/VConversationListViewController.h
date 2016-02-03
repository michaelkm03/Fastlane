//
//  VConversationListViewController.h
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VDeeplinkHandler.h"
#import "VNavigationDestination.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "VMultipleContainer.h"
#import "VAuthorizationContextProvider.h"
#import "VAccessoryNavigationSource.h"
#import "VNoContentView.h"

@class VUnreadMessageCountCoordinator, VConversation, VDependencyManager, ConversationListDataSource;

extern NSString * const VConversationListViewControllerDeeplinkHostComponent; ///< The host component for deepLink URLs that point to inbox messages
extern NSString * const VConversationListViewControllerInboxPushReceivedNotification; ///< Posted when an inbox push notification is received while the app is active

@interface VConversationListViewController : UITableViewController <VDeeplinkSupporter, VMultipleContainerChild, VAuthorizationContextProvider, VNavigationDestination, VAccessoryNavigationSource>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) id<VMultipleContainerChildDelegate> multipleContainerChildDelegate;
@property (nonatomic) NSInteger badgeNumber;
@property (nonatomic, assign) BOOL hasLoadedOnce;

@property (strong, nonatomic) VNoContentView *noContentView;
@property (strong, nonatomic) ConversationListDataSource *dataSource;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)displayConversation:(VConversation *)conversation animated:(BOOL)animated;

@end
