//
//  VTOSViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VWebContentViewController.h"

@interface VTOSViewController : VWebContentViewController

/**
 *  A terms of service viewController. Suitable for pushing inside of a navigation controller. 
 *  Provides a cancel button if presented as the root of a navigation controller.
 */
+ (VTOSViewController *)termsOfServiceViewController;

/**
 *  Presentable terms of service viewController. Provides a mechanism for this viewController to dismiss itself.
 */
+ (UIViewController *)presentableTermsOfServiceViewController;

@end
