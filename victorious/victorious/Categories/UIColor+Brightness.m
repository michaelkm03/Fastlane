//
//  UIColor+Brightness.m
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIColor+Brightness.h"

@implementation UIColor (Brightness)

- (UIColor *)lightenBy:(CGFloat)amount
{
    CGFloat r, g, b, a;
    if ( [self getRed:&r green:&g blue:&b alpha:&a] )
    {
        return [UIColor colorWithRed:MIN( r + amount, 1.0 )
                               green:MIN( g + amount, 1.0 )
                                blue:MIN( b + amount, 1.0 )
                               alpha:a];
    }
    return nil;
}

- (UIColor *)darkenBy:(CGFloat)amount
{
    CGFloat r, g, b, a;
    if ( [self getRed:&r green:&g blue:&b alpha:&a] )
    {
        return [UIColor colorWithRed:MAX( r - amount, 0.0 )
                               green:MAX( g - amount, 0.0 )
                                blue:MAX( b - amount, 0.0 )
                               alpha:a];
    }
    return nil;
}

@end
