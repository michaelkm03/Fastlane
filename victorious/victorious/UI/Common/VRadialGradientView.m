//
//  VRadialGradientView.m
//  RadialGradient
//
//  Created by Michael Sena on 2/7/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import "VRadialGradientView.h"

#import "VRadialGradientLayer.h"

@implementation VRadialGradientView

+ (Class)layerClass
{
    return [VRadialGradientLayer class];
}

#pragma mark - Init

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Property Accessors

- (VRadialGradientLayer *)radialGradientLayer
{
    return (VRadialGradientLayer *)self.layer;
}

- (void)setColors:(NSArray *)colors
{
    NSMutableArray *convertedColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors)
    {
        [convertedColors addObject:(id)color.CGColor];
    }
    [self radialGradientLayer].colors = convertedColors;
}

- (NSArray *)colors
{
    NSMutableArray *convertedColors = [[NSMutableArray alloc] init];
    for (id color in [self radialGradientLayer].colors)
    {
        UIColor *convertedColor = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        [convertedColors addObject:convertedColor];
    }
    return convertedColors;
}

- (void)setInnerCenter:(CGPoint)innerCenter
{
    [self radialGradientLayer].innerCenter = innerCenter;
}

- (CGPoint)innerCenter
{
    return [self radialGradientLayer].innerCenter;
}

- (void)setInnerRadius:(CGFloat)innerRadius
{
    [self radialGradientLayer].innerRadius = innerRadius;
}

- (CGFloat)innerRadius
{
    return [self radialGradientLayer].innerRadius;
}

- (void)setOuterCenter:(CGPoint)outerCenter
{
    [self radialGradientLayer].outerCenter = outerCenter;
}

- (CGPoint)outerCenter
{
    return [self radialGradientLayer].outerCenter;
}

- (void)setOuterRadius:(CGFloat)outerRadius
{
    [self radialGradientLayer].outerRadius = outerRadius;
}

- (CGFloat)outerRadius
{
    return [self radialGradientLayer].outerRadius;
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{    
    for (NSString *animatableProperty in [[self class] animatableKeys])
    {
        if ([event isEqualToString:animatableProperty])
        {
            // Grab a known animateable property action
            CAAnimation *action = (CAAnimation *)[super actionForLayer:layer forKey:@"backgroundColor"];
            if (action != (CAAnimation *)[NSNull null])
            {
                CABasicAnimation *animation = [CABasicAnimation animation];
                animation.fromValue = [[layer presentationLayer] valueForKey:event];
                animation.beginTime = action.beginTime;
                animation.duration = action.duration;
                animation.speed = action.speed;
                animation.timeOffset = action.timeOffset;
                animation.repeatCount = action.repeatCount;
                animation.repeatDuration = action.repeatDuration;
                animation.autoreverses = action.autoreverses;
                animation.timingFunction = action.timingFunction;
                animation.delegate = action.delegate;

                return animation;
            }
            return nil;
        }
    }
    return [super actionForLayer:layer forKey:event];
}

#pragma mark - Private Methods

+ (NSArray *)animatableKeys
{
    return  @[NSStringFromSelector(@selector(colors)),
              NSStringFromSelector(@selector(locations)),
              NSStringFromSelector(@selector(innerCenter)),
              NSStringFromSelector(@selector(innerRadius)),
              NSStringFromSelector(@selector(outerCenter)),
              NSStringFromSelector(@selector(outerRadius))];
}

@end
