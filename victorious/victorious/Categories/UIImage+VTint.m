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

- (UIImage *)v_tintedTemplateImageWithColor:(UIColor *)tintColor
{
    UIImage *tintedImage;
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        // Set blend mode to normal
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // Fill with tint color
        [tintColor setFill];
        CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextFillRect(context, bounds);
        
        // Mask by alpha values of original image
        CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
        CGContextDrawImage(context, bounds, self.CGImage);
        
        tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end
