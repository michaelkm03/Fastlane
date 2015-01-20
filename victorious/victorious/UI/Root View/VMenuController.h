//
//  VMenuController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VNavigationDestinationsProvider.h"
#import "VProvidesNavigationMenuItemBadge.h"

@interface VMenuController : UIViewController <VHasManagedDependancies, VNavigationDestinationsProvider, VProvidesNavigationMenuItemBadge>

@end
