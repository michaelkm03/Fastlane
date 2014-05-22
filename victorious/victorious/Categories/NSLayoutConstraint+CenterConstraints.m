//
//  NSLayoutConstraint+CenterConstraints.m
//  victorious
//
//  Created by Josh Hinman on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSLayoutConstraint+CenterConstraints.h"

@implementation NSLayoutConstraint (CenterConstraints)

+ (NSArray *)v_constraintsToScaleAndCenterView:(UIView *)view withinView:(UIView *)superview withAspectRatio:(CGFloat)aspectRatio
{
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:superview
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0f
                                                                    constant:0.0f];
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:superview
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0f
                                                                    constant:0.0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:superview
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0f
                                                                        constant:0.0f];
    widthConstraint.priority = UILayoutPriorityRequired - 1;
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:aspectRatio
                                                                         constant:0];
    NSLayoutConstraint *maxHeightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationLessThanOrEqual
                                                                              toItem:superview
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1.0f
                                                                            constant:0.0f];
    return @[yConstraint, xConstraint, widthConstraint, heightConstraint, maxHeightConstraint];
}


@end
