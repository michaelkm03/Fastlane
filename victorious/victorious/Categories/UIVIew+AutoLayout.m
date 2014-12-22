//
//  UIView+UIView.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

- (void)addConstraintsToFitContainerView:(UIView *)containerView
{
    NSParameterAssert( containerView == self.superview );
    
    NSDictionary *views = @{ @"view" : self };
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
}

@end
