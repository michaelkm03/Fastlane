//
//  VDiscoverHeaderView.h
//  victorious
//
//  Created by Sharif Ahmed on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

/**
    A simple header view with a 1-line title
 */
@interface VDiscoverHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *title; ///< The title to display in the header
@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependency manager used to style the header

/**
    The desired height for the header
 */
+ (CGFloat)desiredHeight;

/**
    The nib to load the header from
 */
+ (UINib *)nibForHeader;

@end
