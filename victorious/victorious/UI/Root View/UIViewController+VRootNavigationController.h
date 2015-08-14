//
//  UIViewController+VRootNavigationController.h
//  victorious
//
//  Created by Michael Sena on 8/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VRootNavigationController)

/**
 The root Navigation Controller that contains the entire screen. Returns nil if for whatever reason
 we cannot find the rootNavigationController in the viewController hierarchy.
 NOTE: the navigation bar for this NavigationController is hidden.
 */
- (UINavigationController *)rootNavigationController;

@end
