//
//  VTabInfo.h
//  victorious
//
//  Created by Josh Hinman on 6/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VTabInfo;

VTabInfo *v_newTab(UIViewController *viewController, UIImage *icon); ///< Convenience function to create a new VTabInfo instance

/**
 Encapsulates information about a child view controller for VTabBarViewController
 */
@interface VTabInfo : NSObject

@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, readonly) UIImage          *icon;

- (instancetype)initWithViewController:(UIViewController *)viewController icon:(UIImage *)icon;

@end
