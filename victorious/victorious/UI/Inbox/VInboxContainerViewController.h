//
//  VInboxContainerViewController.h
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VProvidesNavigationMenuItemBadge.h"

@interface VInboxContainerViewController : UIViewController <VHasManagedDependancies, VNavigationDestination, VProvidesNavigationMenuItemBadge>

+ (instancetype)inboxContainer;

@end
