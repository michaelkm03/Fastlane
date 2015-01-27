//
//  UIColor+VBrightness.m
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIColor+VBrightness.h"

@implementation UIColor (VBrightness)

- (UIColor *)v_colorLightenedBy:(CGFloat)amount
{
    CGFloat r, g, b, a;
    if ( [self getRed:&r green:&g blue:&b alpha:&a] )
    {
        return [UIColor colorWithRed:r + (1.0 - r) * amount
                               green:g + (1.0 - g) * amount
                                blue:b + (1.0 - b) * amount
                               alpha:a];
    }
    return nil;
}

- (UIColor *)v_colorDarkenedBy:(CGFloat)amount
{
    CGFloat r, g, b, a;
    if ( [self getRed:&r green:&g blue:&b alpha:&a] )
    {
        return [UIColor colorWithRed:r - r * amount
                               green:g - g * amount
                                blue:b - b * amount
                               alpha:a];
    }
    return nil;
}

@end