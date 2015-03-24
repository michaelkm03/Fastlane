//
//  UIColor+VBrightness.m
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIColor+VBrightness.h"

@implementation UIColor (VBrightness)

- (VColorLuminance)v_colorLuminance
{
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    
    if ( ![self getRed:&red green:&green blue:&blue alpha:&alpha] )
    {
        return VColorLuminanceDark;
    }
    
    // Relative luminance in colorimetric spaces - http://en.wikipedia.org/wiki/Luminance_(relative)
    red *= 0.2126f;
    green *= 0.7152f;
    blue *= 0.0722f;
    CGFloat luminance = red + green + blue;
    
    if ( luminance < 0.6f )
    {
        return VColorLuminanceDark;
    }
    else
    {
        return VColorLuminanceBright;
    }

}

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
