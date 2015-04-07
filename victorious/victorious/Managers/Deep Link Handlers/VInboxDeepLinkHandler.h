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

@class VInboxContainerViewController;

/**
 Handles deep links related to inbox and messaging.
 */
@interface VInboxDeepLinkHandler : NSObject <VDeeplinkHandler>

/**
 The inbox view controller that will be presented if validation and
 loading of data succeeds.
 */
@property (nonatomic, weak) VInboxContainerViewController *inboxContainerViewController;

@end
