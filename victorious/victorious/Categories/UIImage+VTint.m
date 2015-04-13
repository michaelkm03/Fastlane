//
//  UIImage+VTint.m
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+VTint.h"

@implementation UIImage (VTint)

- (UIImage *)v_tintedImageWithColor:(UIColor *)tintColor alpha:(CGFloat)alpha blendMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions( self.size, NO, 0.0f );
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill( bounds );
    
    [self drawInRect:bounds blendMode:blendMode alpha:alpha];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (UIImage *)v_tintedCIImageWithColor:(UIColor *)tintColor alpha:(CGFloat)alpha blendMode:(CGBlendMode)blendMode
{
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    [colorFilter setValue:tintColor forKey:kCIInputColorKey];
    CIImage *colorImage = colorFilter.outputImage;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [filter setValue:colorImage forKey:kCIInputImageKey];
    [filter setValue:inputImage forKey:kCIInputBackgroundImageKey];
    CIImage *outputImage = filter.outputImage;
    
    return [UIImage imageWithCIImage:outputImage];
}

@end
