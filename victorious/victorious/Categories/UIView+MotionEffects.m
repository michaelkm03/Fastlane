//
//  UIView+MotionEffects.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+MotionEffects.h"

#import <objc/runtime.h>

static const char kAssociatedObjectKey;

@implementation UIView (MotionEffects)

- (void)v_addMotionEffectsWithMagnitude:(CGFloat)magnitude
{
    UIMotionEffectGroup *oldMotionEffects = objc_getAssociatedObject(self, &kAssociatedObjectKey);
    if (oldMotionEffects != nil)
    {
        [self removeMotionEffect:oldMotionEffects];
    }
    
    UIInterpolatingMotionEffect *xMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xMotionEffect.maximumRelativeValue = @(magnitude);
    xMotionEffect.minimumRelativeValue = @(-magnitude);
    
    UIInterpolatingMotionEffect *yMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yMotionEffect.maximumRelativeValue = @(-magnitude);
    yMotionEffect.minimumRelativeValue = @(magnitude);
    
    UIMotionEffectGroup *motionEffectsGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectsGroup.motionEffects = @[xMotionEffect, yMotionEffect];
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey, motionEffectsGroup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addMotionEffect:motionEffectsGroup];
}

@end
