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

- (NSLayoutConstraint *)v_addWidthConstraint:(CGFloat)width
{
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:width];
    [self addConstraint:widthConstraint];
    return widthConstraint;
}

- (NSLayoutConstraint *)v_addHeightConstraint:(CGFloat)height
{
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0f
                                                                         constant:height];
    [self addConstraint:heightConstraint];
    return heightConstraint;
}

- (void)v_addPinToLeadingTrailingToSubview:(UIView *)subView
{
    NSParameterAssert( [subView isDescendantOfView:self] );
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[subView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(subView)]];
}

- (void)v_addPintoTopBottomToSubview:(UIView *)subView
{
    NSParameterAssert( [subView isDescendantOfView:self] );
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(subView)]];
}

- (void)v_addPinToTopToSubview:(UIView *)subview
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(subview)]];
}

- (void)v_addPinToBottomToSubview:(UIView *)subview
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subview]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(subview)]];
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

- (NSLayoutConstraint *)v_internalHeightConstraint
{
    __block NSLayoutConstraint *internalHeightConstraint;
    
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
    {
        if (constraint.secondItem != nil)
        {
            return;
        }
        if (constraint.firstAttribute != NSLayoutAttributeHeight)
        {
            return;
        }
        internalHeightConstraint = constraint;
        *stop = YES;
    }];
    return internalHeightConstraint;
}

@end
