//
//  UIView+VDynamicsHelpers.m
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+VDynamicsHelpers.h"

static const CGFloat kUIKitNewtonScaling = 1000000.0;

@implementation UIView (VDynamicsHelpers)

- (UIOffset)v_centerOffsetForPoint:(CGPoint)point
{
    return UIOffsetMake(point.x - CGRectGetMidX(self.bounds), point.y - CGRectGetMidY(self.bounds));
}

- (CGVector)v_forceFromVelocity:(CGPoint)velocityInView
{
    return [self v_forceFromVelocity:velocityInView withDensity:1.0];
}

- (CGVector)v_forceFromVelocity:(CGPoint)velocityInView withDensity:(CGFloat)density
{
    CGRect bounds = self.bounds;
    CGFloat area = CGRectGetWidth(bounds) * CGRectGetHeight(bounds);
    const CGFloat UIKitNewtonScaling = kUIKitNewtonScaling;
    CGFloat scaling = density*area/UIKitNewtonScaling;
    
    return CGVectorMake(velocityInView.x * scaling, velocityInView.y * scaling);
}

@end
