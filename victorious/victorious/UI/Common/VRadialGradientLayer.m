//
//  VRadialGradientLayer.m
//  RadialGradient
//
//  Created by Michael Sena on 2/7/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import "VRadialGradientLayer.h"
#import <UIKit/UIKit.h>

@implementation VRadialGradientLayer

@dynamic colors;
@dynamic innerRadius;
@dynamic innerCenter;
@dynamic outerCenter;
@dynamic outerRadius;

#pragma mark - CALayer

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    for (NSString *animatableKey in [self animatableKeys])
    {
        if ([key isEqualToString:animatableKey])
        {
            return YES;
        }
    }
    
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)key
{
    id <CAAction> action = [super actionForKey:key];
    if (action == [NSNull null])
    {
        for (NSString *animatableKey in [[self class] animatableKeys])
        {
            if ([key isEqualToString:animatableKey])
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
                animation.fromValue = [self.presentationLayer valueForKey:key];
                return animation;
            }
        }
    }
    return action;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpace, (CFArrayRef) self.colors, NULL);
    
    CGContextDrawRadialGradient(ctx,
                                gradientRef,
                                self.innerCenter,
                                self.innerRadius,
                                self.outerCenter,
                                self.outerRadius,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpace);
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
