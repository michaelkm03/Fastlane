//
//  VMenuController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

extern NSString * const VMenuControllerDidSelectRowNotification; ///< Posted when a menu item is selected
extern NSString * const VMenuControllerDestinationViewControllerKey; ///< User info dictionary key for the view controller corresponding to a selected menu item

@interface VMenuController : UIViewController <VHasManagedDependancies>

@end
