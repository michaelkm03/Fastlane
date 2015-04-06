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

@interface VInboxDeepLinkHandler : NSObject <VDeeplinkHandler>

@property (nonatomic, weak) VInboxContainerViewController *inboxContainerViewController;

@end
