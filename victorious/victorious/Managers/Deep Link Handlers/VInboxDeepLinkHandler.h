//
//  VInboxDeepLinkHandler.h
//  victorious
//
//  Created by Patrick Lynch on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VNavigationDestination.h"
#import "VDeeplinkHandler.h"

@class VInboxContainerViewController, VDependencyManager;

/**
 Handles deep links related to inbox and messaging.
 */
@interface VInboxDeepLinkHandler : NSObject <VDeeplinkHandler>

/**
 Initialize with required  dependency manager and required inbox view controller that will
 be presented if validation and loading of data succeeds.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
             inboxContainerViewController:(VInboxContainerViewController *)inboxContainerViewController NS_DESIGNATED_INITIALIZER;

@end
