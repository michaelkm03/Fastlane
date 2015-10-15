//
//  UIImage+VSolidColor.m
//  victorious
//
//  Created by Josh Hinman on 5/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+VSolidColor.h"

@implementation UIImage (VSolidColor)

+ (UIImage *)v_imageWithColor:(UIColor *)color
{
    return [self v_imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)v_singlePixelImageWithColor:(UIColor *)color
{
    CGFloat inverseScale = 1.0f / [UIScreen mainScreen].scale;
    return [self v_imageWithColor:color size:CGSizeMake(inverseScale, inverseScale)];
}

+ (UIImage *)v_imageWithColor:(UIColor *)color
                         size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    UIRectFill(CGRectMake(0.0f, 0.0f, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
