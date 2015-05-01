//
//  UIImage+VTint.m
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+VTint.h"
#import "UIImage+Resize.h"

@implementation UIImage (VTint)

- (UIImage *)v_tintedImageWithColor:(UIColor *)tintColor alpha:(CGFloat)alpha blendMode:(CGBlendMode)blendMode
{
    UIImage *tintedImage;
    UIGraphicsBeginImageContextWithOptions( self.size, NO, 0.0f );
    {
        [tintColor setFill];
        CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
        UIRectFill( bounds );
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), [self transformForCurrentOrientationWithSize:self.size]);
        [self drawInRect:bounds blendMode:blendMode alpha:alpha];
        tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:tintedImage.CGImage scale:self.scale orientation:self.imageOrientation];
}

@end
