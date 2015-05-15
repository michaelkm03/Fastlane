//
//  VMultipleContainer.h
//  victorious
//
//  Created by Josh Hinman on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

#import "VAuthorizationContextProvider.h"

#import "VInitialViewController.h"

/**
 *  Similar to a UITabBarController, except the tab bar
 *  is at the top and isn't necessarily a tab bar.
 *
 *  Forwards VAuthorizationContextProvider methods to the
 *  currently selected viewController.
 */
@interface VMultipleContainerViewController : UIViewController <VHasManagedDependencies, VMultipleContainer, VAuthorizationContextProvider, VInitialViewController>

@property (nonatomic, copy) NSArray /* UIViewController */ *viewControllers; ///< The view controllers to be displayed
@property (nonatomic, assign) BOOL isInitialViewController;

@end
