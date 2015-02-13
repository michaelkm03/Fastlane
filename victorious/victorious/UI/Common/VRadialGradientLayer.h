//
//  VRadialGradientLayer.h
//  RadialGradient
//
//  Created by Michael Sena on 2/7/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface VRadialGradientLayer : CALayer

/**
 *  An array of CGColors to distribute throughout the radial gradient. Behaves like CAGradientLayer's colors property. Animatable.
 */
@property (nonatomic, copy) NSArray *colors;

/**
 *  The inner circle center. Animatable.
 */
@property (nonatomic) CGPoint innerCenter;

/**
 *  The inner circle radius. Animatable.
 */
@property (nonatomic) CGFloat innerRadius;

/**
 *  The outer circle center. Animatable.
 */
@property (nonatomic) CGPoint outerCenter;

/**
 *  The outer circle radius. Animatable.
 */
@property (nonatomic) CGFloat outerRadius;

@end
