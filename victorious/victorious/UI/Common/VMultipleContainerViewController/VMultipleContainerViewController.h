//
//  VMultipleContainerViewController.h
//  victorious
//
//  Created by Josh Hinman on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

/**
 Similar to a UITabBarController, except the tab bar
 is at the top and isn't necessarily a tab bar.
 */
@interface VMultipleContainerViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, copy) NSArray /* UIViewController */ *viewControllers; ///< The view controllers to be displayed

@end
