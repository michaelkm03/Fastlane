//
//  VLinearGradientView.m
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLinearGradientView.h"

#import "NSArray+VMap.h"

@implementation VLinearGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer *)self.layer;
}

- (void)setColors:(NSArray *)colors
{
    [[self gradientLayer] setColors:[colors v_map:^id(UIColor *color)
    {
        return (id)color.CGColor;
    }]];
}

- (void)setLocations:(NSArray *)locations
{
    [[self gradientLayer] setLocations:locations];
}

- (NSArray *)locations
{
    return [[self gradientLayer] locations];
}

- (void)setStartPoint:(CGPoint)startPoint
{
    [[self gradientLayer] setStartPoint:startPoint];
}

- (CGPoint)startPoint
{
    return [[self gradientLayer] startPoint];
}

- (void)setEndPoint:(CGPoint)endPoint
{
    [[self gradientLayer] setEndPoint:endPoint];
}

- (CGPoint)endPoint
{
    return [[self gradientLayer] endPoint];
}

@end
