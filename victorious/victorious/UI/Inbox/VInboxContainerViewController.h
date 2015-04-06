//
//  VInboxContainerViewController.h
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDeeplinkHandler.h"
#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VProvidesNavigationMenuItemBadge.h"

@class VInboxViewController;

extern NSString * const VInboxContainerViewControllerDeeplinkHostComponent; ///< The host component for deeplink URLs that point to inbox messages
extern NSString * const VInboxContainerViewControllerInboxPushReceivedNotification; ///< Posted when an inbox push notification is received while the app is active

@interface VInboxContainerViewController : UIViewController <VDeeplinkSupporter, VHasManagedDependencies, VNavigationDestination, VProvidesNavigationMenuItemBadge>

+ (instancetype)inboxContainer;

@property (weak, nonatomic, readonly) VInboxViewController *inboxViewController;

@end
