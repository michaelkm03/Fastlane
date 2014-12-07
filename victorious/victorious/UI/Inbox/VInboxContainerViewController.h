//
//  VInboxContainerViewController.h
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VTableContainerViewController.h"
#import "VProvidesNavigationMenuItemBadge.h"

@interface VInboxContainerViewController : VTableContainerViewController <VHasManagedDependancies, VNavigationDestination, VProvidesNavigationMenuItemBadge>

+ (instancetype)inboxContainer;

@end
