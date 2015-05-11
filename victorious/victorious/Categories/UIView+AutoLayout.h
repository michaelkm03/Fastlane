//
//  UIView+Autolayout.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)


/**
 Applies constraints necessary to fit the subview's leading, trailing space to this
 view as its container with constant values provided.  Uses VFL like si:
 `H:|-leading-[subview]-trailing-|`
 */
- (void)v_addPinToLeadingTrailingToSubview:(UIView *)subview
                                   leading:(CGFloat)leading
                                  trailing:(CGFloat)trailing;
/**
 Applies constraints necessary to fit the subview's top and bottom space to this view
 as its container with constant values provided.  Uses VFL like si:
 `H:|-leading-[subview]-trailing-|`
 `V:|-top-[subview]-bottom-|`
 */
- (void)v_addPintoTopBottomToSubview:(UIView *)subview
                                 top:(CGFloat)top
                              bottom:(CGFloat)bottom;
/**
 Applies constraints necessary to fit the subview's leading, trailing, top and bottom
 space to this view as its container with constant values provided.  Uses VFL like si:
 `H:|-leading-[subview]-trailing-|`
 `V:|-top-[subview]-bottom-|`
 */
- (void)v_addFitToParentConstraintsToSubview:(UIView *)subview
                                   leading:(CGFloat)leading
                                  trailing:(CGFloat)trailing
                                       top:(CGFloat)top
                                    bottom:(CGFloat)bottom;

/**
 Calls method `addFitToParentConstraintsToSubview:leading:trailing:top:bottom:' but
 provides the `space` param to all values, leading, trailing, top and bottom.
 */
- (void)v_addFitToParentConstraintsToSubview:(UIView *)subview
                                     space:(CGFloat)space;

/**
 Calls method `addFitToParentConstraintsToSubview:leading:trailing:top:bottom:' but
 sets leading, trailing, top and bottom values to zero;
 */
- (void)v_addFitToParentConstraintsToSubview:(UIView *)subview;

/**
 Applies left to left and right to right constraints from the container view to the
 passed in subview.
 */
- (void)v_addPinToLeadingTrailingToSubview:(UIView *)subView;

/**
 Applies centering to subview of both horizontal and verticall
 directions to superview.
 */
- (void)v_addCenterToParentContraintsToSubview:(UIView *)subview;

/**
 Applies top to top and bottom to bottom constraints form the container view ot the
 passed in subview.
 */
- (void)v_addPintoTopBottomToSubview:(UIView *)subView;

/**
 Applies top to top constraint from the container to the passed in subview.
 */
- (void)v_addPinToTopToSubview:(UIView *)subview;

/**
 Applies bottom to bottom constraint from the container to the passed in subview.
 */
- (void)v_addPinToBottomToSubview:(UIView *)subview;

/**
 Applies internal width constraint to view. Returns the added constraint
 */
- (NSLayoutConstraint *)v_addWidthConstraint:(CGFloat)width;

/**
 Applies internal height constraint to view. Returns the added constraint
 */
- (NSLayoutConstraint *)v_addHeightConstraint:(CGFloat)height;

/**
 Returns the first width constraint found by enumerating constraints according
 to the following criteria:
    1. secondItem is nil
    2. firstAttribute == NSLayoutAttributeWidth
 */
- (NSLayoutConstraint *)v_internalWidthConstraint;

/**
 Returns the first height constraint found by enumerating constraints according
 to the following criteria:
 1. secondItem is nil
 2. firstAttribute == NSLayoutAttributeHeight
 */
- (NSLayoutConstraint *)v_internalHeightConstraint;

@end
