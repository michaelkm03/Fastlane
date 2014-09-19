//
//  UIView+VShadows.m
//  victorious
//
//  Created by Michael Sena on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+VShadows.h"

@implementation UIView (VShadows)

- (void)v_applyShadowsWithZIndex:(CGFloat)zIndex
{
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = (zIndex * 1.8f);
    
    UIMotionEffectGroup *shadowEffects = [[UIMotionEffectGroup alloc] init];
    
    UIInterpolatingMotionEffect *xShadowEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset.width" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xShadowEffect.maximumRelativeValue = @(zIndex*10);
    xShadowEffect.minimumRelativeValue = @(-zIndex*10);
    
    UIInterpolatingMotionEffect *yShadowEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset.height" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yShadowEffect.maximumRelativeValue = @(zIndex*10);
    yShadowEffect.minimumRelativeValue = @(-zIndex*10);
    
    
    shadowEffects.motionEffects = @[xShadowEffect,  yShadowEffect];
    
    [self addMotionEffect:shadowEffects];
}

@end
