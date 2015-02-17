//
//  UIViewController+VLayoutInsets.h
//  victorious
//
//  Created by Josh Hinman on 1/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VLayoutInsets)

/**
 Returns suggested insets for this view controller's content.
 E.g., when the view's bounds extend underneath a navigation
 bar, the navigation bar's height will be reflected in the
 top inset.
 
 It is the parent view controller's responsibility to set
 this property. If you are added as a child of a view
 controller that does not implement this functionality,
 this property will not be correct.
 
 Additionally, these insets may change at any time. It is
 recommended that you override the setter to perform any
 layout adjustments needed in response.
 */
@property (nonatomic, setter=v_setLayoutInsets:) UIEdgeInsets v_layoutInsets;

@end
