//
//  UIView+UIView.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

- (void)addFitToParentConstraintsToSubview:(UIView *)subview
                                   leading:(CGFloat)leading
                                  trailing:(CGFloat)trailing
                                       top:(CGFloat)top
                                    bottom:(CGFloat)bottom
{
    NSParameterAssert( subview.superview == self );
    
    NSDictionary *views = @{ @"subview" : subview };
    NSDictionary *metrics = @{ @"leading" : @(leading),
                               @"trailing" : @(trailing),
                               @"top" : @(top),
                               @"bottom" : @(bottom) };
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-leading-[subview]-trailing-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-top-[subview]-bottom-|"
                                                                 options:kNilOptions
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)addFitToParentConstraintsToSubview:(UIView *)subview
                                     space:(CGFloat)space
{
    [self addFitToParentConstraintsToSubview:subview
                                     leading:space
                                    trailing:space
                                         top:space
                                      bottom:space];
}

- (void)addFitToParentConstraintsToSubview:(UIView *)subview
{
    [self addFitToParentConstraintsToSubview:subview
                                     leading:0.0
                                    trailing:0.0
                                         top:0.0
                                      bottom:0.0];
}

@end
