//
//  UIViewController+ForceOrientationChange.h
//  victorious
//
//  Created by Josh Hinman on 5/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ForceOrientationChange)

/**
 Forces the system to re-query the supported
 interface orientations for the root view
 controller and adjust accordingly.
 */
+ (void)v_forceOrientationChange;

@end
