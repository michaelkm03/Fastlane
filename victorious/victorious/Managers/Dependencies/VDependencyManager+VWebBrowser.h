//
//  VDependencyManager+VWebBrowser.h
//  victorious
//
//  Created by Patrick Lynch on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VDependencyManagerWebBrowserLayoutKey;              ///< Key for specifiying top vs. bottom nav layout
extern NSString * const VDependencyManagerWebBrowserLayoutTopNavigation;    ///< Browser header bar and navigation controls on top
extern NSString * const VDependencyManagerWebBrowserLayoutBottomNavigation; ///< Browser header bar and navigation controls on bottom

@class VWebBrowserViewController;

@interface VDependencyManager (VWebBrowser)

@end
