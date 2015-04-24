//
//  VSlantView.m
//  victorious
//
//  Created by Michael Sena on 4/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSlantView.h"

@implementation VSlantView

#pragma mark - UIView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)_shapeLayer
{
    return (CAShapeLayer *)self.layer;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *slantShape = [UIBezierPath bezierPath];
    [slantShape moveToPoint:self.bounds.origin];
    [slantShape addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds))];
    [slantShape addLineToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds))];
    [slantShape closePath];
    [[self _shapeLayer] setPath:slantShape.CGPath];
}

- (void)setSlantColor:(UIColor *)slantColor
{
    [[self _shapeLayer] setFillColor:slantColor.CGColor];
}

- (UIColor *)slantColor
{
    return [UIColor colorWithCGColor:[[self _shapeLayer] fillColor]];
}

@end
