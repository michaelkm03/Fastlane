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

@interface VInboxContainerViewController : UIViewController <VDeeplinkHandler, VHasManagedDependancies, VNavigationDestination, VProvidesNavigationMenuItemBadge>

+ (instancetype)inboxContainer;

@end
