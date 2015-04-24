//
//  UIView+UIView.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+Autolayout.h"

@implementation UIView (AutoLayout)

- (void)v_addFitToParentConstraintsToSubview:(UIView *)subview
                                   leading:(CGFloat)leading
                                  trailing:(CGFloat)trailing
                                       top:(CGFloat)top
                                    bottom:(CGFloat)bottom
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    NSDictionary *views = @{ @"subview" : subview };
    NSDictionary *metrics = @{ @"leading" : @(leading),
                               @"trailing" : @(trailing),
                               @"top" : @(top),
                               @"bottom" : @(bottom) };
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[subview]-trailing-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[subview]-bottom-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)v_addFitToParentConstraintsToSubview:(UIView *)subview
                                     space:(CGFloat)space
{
    [self v_addFitToParentConstraintsToSubview:subview
                                     leading:space
                                    trailing:space
                                         top:space
                                      bottom:space];
}

- (void)v_addFitToParentConstraintsToSubview:(UIView *)subview
{
    [self v_addFitToParentConstraintsToSubview:subview
                                     leading:0.0
                                    trailing:0.0
                                         top:0.0
                                      bottom:0.0];
}

- (void)v_addCenterToParentContraintsToSubview:(UIView *)subview
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)v_addWidthConstraint:(CGFloat)width
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:width]];
}

- (void)v_addHeightConstraint:(CGFloat)height
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:height]];
}

- (NSLayoutConstraint *)v_internalWidthConstraint
{
    __block NSLayoutConstraint *internalWidthConstraint;
    
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
     {
         if (constraint.secondItem != nil)
         {
             return;
         }
         if (constraint.firstAttribute != NSLayoutAttributeWidth)
         {
             return;
         }
         internalWidthConstraint = constraint;
         *stop = YES;
     }];
    
    return internalWidthConstraint;
}

@end
