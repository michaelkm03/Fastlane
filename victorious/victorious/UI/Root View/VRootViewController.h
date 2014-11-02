//
//  VRootViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSideMenuViewController.h"

@interface VRootViewController : UIViewController

/**
 The view controller that is currently being displayed
 */
@property (nonatomic, strong, readonly) UIViewController *currentViewController;

+ (instancetype)rootViewController; ///< NOT A CONSTRUCTOR/FACTORY METHOD. Convenient, typed alias for [[[UIApplication sharedApplication] keyWindow] rootViewController]

- (void)presentForceUpgradeScreen;

@end
