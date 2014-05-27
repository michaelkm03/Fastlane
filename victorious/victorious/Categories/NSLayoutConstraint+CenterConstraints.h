//
//  NSLayoutConstraint+CenterConstraints.h
//  victorious
//
//  Created by Josh Hinman on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (CenterConstraints)

/**
 Returns a set of constraints that will center one view within another, and scale
 it to the maximum size possible while keeping it within the bounds of the other
 view and preserving a specific aspect ratio.
 
 @param aspectRatio The ratio of width / height
 */
+ (NSArray *)v_constraintsToScaleAndCenterView:(UIView *)view withinView:(UIView *)superview withAspectRatio:(CGFloat)aspectRatio;

@end
