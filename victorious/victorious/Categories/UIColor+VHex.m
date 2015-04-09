//
//  UIColor+VHex.m
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIColor+VHex.h"

@implementation UIColor (VHex)

- (NSString *)v_hexString
{
    // This method only works for RGB colors
    if ( CGColorGetNumberOfComponents( self.CGColor ) == 4 )
    {
        const CGFloat *components = CGColorGetComponents( self.CGColor );
        CGFloat red, green, blue;
        red = roundf( components[0] * 255.0 );
        green = roundf( components[1] * 255.0 );
        blue = roundf( components[2] * 255.0 );
        
        // Convert with %02x (use 02 to always get two chars)
        return [[NSString alloc]initWithFormat:@"%02x%02x%02x", (int)red, (int)green, (int)blue];
    }
    
    return nil;
}

@end
