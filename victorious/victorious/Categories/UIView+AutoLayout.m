//
//  UIView+UIView.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+Autolayout.h"

@implementation UIView (AutoLayout)

- (void)v_addPinToLeadingTrailingToSubview:(UIView *)subview
                                   leading:(CGFloat)leading
                                  trailing:(CGFloat)trailing
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    NSDictionary *views = @{ @"subview" : subview };
    NSDictionary *metrics = @{ @"leading" : @(leading),
                               @"trailing" : @(trailing)
                               };
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[subview]-trailing-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)v_addPintoTopBottomToSubview:(UIView *)subview
                                 top:(CGFloat)top
                              bottom:(CGFloat)bottom
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    NSDictionary *views = @{ @"subview" : subview };
    NSDictionary *metrics = @{@"top" : @(top),
                              @"bottom" : @(bottom) };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[subview]-bottom-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)v_addVerticalMinimumSpacingToSubview:(UIView *)subview spacing:(CGFloat)space
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    NSDictionary *views = @{ @"subview" : subview };
    NSDictionary *metrics = @{@"top" : @(space),
                              @"bottom" : @(space) };
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=top-[subview]->=bottom-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)v_addHorizontalMinimumSpacingToSubview:(UIView *)subview spacing:(CGFloat)space
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    NSDictionary *views = @{ @"subview" : subview };
    NSDictionary *metrics = @{ @"leading" : @(space),
                               @"trailing" : @(space)
                               };
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=leading-[subview]->=trailing-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)v_addPinToLeadingTrailingToSubview:(UIView *)subView
{
    [self v_addPinToLeadingTrailingToSubview:subView
                                     leading:0.0f
                                    trailing:0.0f];
}

- (void)v_addPinToTopBottomToSubview:(UIView *)subView
{
    [self v_addPintoTopBottomToSubview:subView
                                   top:0.0f
                                bottom:0.0f];
}

- (void)v_addCenterAndFitToParentConstraintsToSubview:(UIView *)subview
                                                width:(CGFloat)widthPercentage
                                                height:(CGFloat)heightPercentage
{
    [self v_addCenterToParentContraintsToSubview:subview];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:widthPercentage
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:heightPercentage
                                                      constant:0.0f]];
}

- (void)v_addFitToParentConstraintsToSubview:(UIView *)subview
                                     leading:(CGFloat)leading
                                    trailing:(CGFloat)trailing
                                         top:(CGFloat)top
                                      bottom:(CGFloat)bottom
{
    [self v_addPinToLeadingTrailingToSubview:subview leading:leading trailing:trailing];
    [self v_addPintoTopBottomToSubview:subview top:top bottom:bottom];
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
    [self v_addCenterHorizontallyConstraintsToSubview:subview];
    [self v_addCenterVerticallyConstraintsToSubview:subview];
}

- (void)v_addCenterVerticallyConstraintsToSubview:(UIView *)subview
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)v_addCenterHorizontallyConstraintsToSubview:(UIView *)subview
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

- (void)v_addPinToTopToSubview:(UIView *)subview
{
    [self v_addPinToTopToSubview:subview topMargin:0.0f];
}

- (void)v_addPinToTopToSubview:(UIView *)subview topMargin:(CGFloat)margin
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[subview]"
                                                                 options:kNilOptions
                                                                 metrics:@{ @"margin" : @(margin) }
                                                                   views:NSDictionaryOfVariableBindings(subview)]];
}

- (void)v_addPinToBottomToSubview:(UIView *)subview
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    [self v_addPinToBottomToSubview:subview bottomMargin:0.0f];
}

- (void)v_addPinToBottomToSubview:(UIView *)subview bottomMargin:(CGFloat)margin
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subview]-margin-|"
                                                                 options:kNilOptions
                                                                 metrics:@{ @"margin" : @(margin) }
                                                                   views:NSDictionaryOfVariableBindings(subview)]];
}

- (void)v_addPinToLeadingEdgeToSubview:(UIView *)subview
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    [self v_addPinToLeadingEdgeToSubview:subview leadingMargin:0.0f];
}

- (void)v_addPinToLeadingEdgeToSubview:(UIView *)subview leadingMargin:(CGFloat)margin
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[subview]"
                                                                 options:kNilOptions
                                                                 metrics:@{ @"margin" : @(margin) }
                                                                   views:NSDictionaryOfVariableBindings(subview)]];
}

- (void)v_addPinToTrailingEdgeToSubview:(UIView *)subview
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    [self v_addPinToTrailingEdgeToSubview:subview trailingMargin:0.0f];
}

- (void)v_addPinToTrailingEdgeToSubview:(UIView *)subview trailingMargin:(CGFloat)margin
{
    NSParameterAssert( [subview isDescendantOfView:self] );
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview]-margin-|"
                                                                 options:kNilOptions
                                                                 metrics:@{ @"margin" : @(margin) }
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
         if ( internalWidthConstraint == nil || constraint.constant > internalWidthConstraint.constant )
         {
             internalWidthConstraint = constraint;
         }
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
        if ( internalHeightConstraint == nil || constraint.constant > internalHeightConstraint.constant )
        {
            internalHeightConstraint = constraint;
        }
    }];
    return internalHeightConstraint;
}

@end
