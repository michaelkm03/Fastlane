//
//  VPrivacyPoliciesViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VWebContentViewController.h"

@class VDependencyManager;

@interface VPrivacyPoliciesViewController : VWebContentViewController

/**
 *  Presentable terms of service viewController. Provides a mechanism for this viewController to dismiss itself.
 */
+ (UIViewController *)presentableTermsOfServiceViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The dependency manager for the privacy policy.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
