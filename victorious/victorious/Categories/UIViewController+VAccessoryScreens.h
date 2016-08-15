//
//  UIViewController+VAccessoryScreens.h
//  victorious
//
//  Created by Sharif Ahmed on 7/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

/**
    Methods for simplifying managing accessory screens in view controllers
 */
@interface UIViewController (VAccessoryScreens)

/**
    Adds accessory screens to the view controller from the provided dependency manager.
        Should be called from viewWillAppear:
 */
- (void)v_addAccessoryScreensWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
