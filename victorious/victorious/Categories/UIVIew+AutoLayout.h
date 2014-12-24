//
//  UIView+AutoLayout.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)

/**
 Applies constraints necessary to fit the subview's leading, trailing, top and bottom
 space to this view as its container with constant values provided.  Uses VFL like si:
 `H:|-leading-[subview]-trailing-|`
 `V:|-top-[subview]-bottom-|`
 */
- (void)addFitToParentConstraintsToSubview:(UIView *)subview
                                   leading:(CGFloat)leading
                                  trailing:(CGFloat)trailing
                                       top:(CGFloat)top
                                     ottom:(CGFloat)bottom;

/**
 Calls method `addFitToParentConstraintsToSubview:leading:trailing:top:bottom:' but
 provides the `space` param to all values, leading, trailing, top and bottom.
 */
- (void)addFitToParentConstraintsToSubview:(UIView *)subview
                                     space:(CGFloat)space;

/**
 Calls method `addFitToParentConstraintsToSubview:leading:trailing:top:bottom:' but
 sets leading, trailing, top and bottom values to zero;
 */
- (void)addFitToParentConstraintsToSubview:(UIView *)subview;

@end
