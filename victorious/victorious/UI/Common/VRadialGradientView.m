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

@end
