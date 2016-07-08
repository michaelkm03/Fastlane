//
//  VConversationListViewController.h
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VNavigationDestination.h"
#import "VMultipleContainer.h"
#import "VAuthorizationContextProvider.h"
#import "VAccessoryNavigationSource.h"

@class VUnreadMessageCountCoordinator, VConversation, VDependencyManager, VNoContentView, ConversationListDataSource;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const VConversationListViewControllerDeeplinkHostComponent; ///< The host component for deepLink URLs that point to inbox messages
extern NSString * const VConversationListViewControllerInboxPushReceivedNotification; ///< Posted when an inbox push notification is received while the app is active

@interface VConversationListViewController : UITableViewController <VMultipleContainerChild, VAuthorizationContextProvider, VNavigationDestination, VAccessoryNavigationSource>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) id<VMultipleContainerChildDelegate> multipleContainerChildDelegate;
@property (nonatomic) NSInteger badgeNumber;
@property (nonatomic, assign) BOOL shouldAnimateDataSourceChanges;
@property (strong, nonatomic) VNoContentView *noContentView;
@property (strong, nonatomic) ConversationListDataSource *dataSource;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;


/*
 * Shows a conversation in the inbox. The conversation should never be nil.
 */
- (void)showConversation:(VConversation *)conversation animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
