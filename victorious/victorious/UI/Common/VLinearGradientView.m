//
//  VLinearGradientView.m
//  victorious
//
//  Created by Patrick Lynch on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLinearGradientView.h"
#import "NSArray+VMap.h"

@interface VLinearGradientView()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end


@implementation VLinearGradientView

- (void)setColors:(NSArray *)colors
{
    _colors = [colors copy];
    self.gradientLayer.colors = [_colors v_map:^id(UIColor *color)
                                 {
                                     return (id)color.CGColor;
                                 }];
    [self setNeedsDisplay];
}

- (void)setLocations:(NSArray *)locations
{
    _locations = [locations copy];
    self.gradientLayer.locations = _locations;
    [self setNeedsDisplay];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    _gradientLayer.frame = self.bounds;
}

- (CAGradientLayer *)gradientLayer
{
    if ( _gradientLayer == nil )
    {
        _gradientLayer = [CAGradientLayer layer];
        [self.layer addSublayer:_gradientLayer];
        self.layer.mask = _gradientLayer;
    }
    
    _gradientLayer.frame = self.bounds;
    _gradientLayer.locations = self.locations ?: @[ @0, @1 ];
    _gradientLayer.colors = [self.colors v_map:^id(UIColor *color)
                             {
                                 return (id)color.CGColor;
                             }];
    
    return _gradientLayer;
}

@end
