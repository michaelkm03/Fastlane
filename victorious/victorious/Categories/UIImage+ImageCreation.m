//
//  UIImage+ImageCreation.m
//  victorious
//
//  Created by Will Long on 3/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageCreation.h"

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

@implementation UIImage (ImageCreation)

+ (UIImage *)resizeableImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 3.0f, 3.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    return image;
}

//As suggest by iamamused http://stackoverflow.com/questions/19274789/change-image-tintcolor-in-ios7
- (UIImage *)v_imageByMaskingImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RadiansToDegrees( radians )];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    UIView *rotatedView = [[UIView alloc] initWithFrame:CGRectMake( 0.0, 0.0, self.size.width, self.size.height )];
    rotatedView.transform = CGAffineTransformMakeRotation( DegreesToRadians( degrees ) );
    CGSize outputSize = rotatedView.frame.size;
    
    UIGraphicsBeginImageContext( outputSize );
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM( context, outputSize.width * 0.5, outputSize.height * 0.5 );
    CGContextRotateCTM( context, DegreesToRadians( degrees ) );
    CGContextScaleCTM( context, 1.0, -1.0 );
    CGContextDrawImage( context, CGRectMake( -self.size.width * 0.5, -self.size.height * 0.5, self.size.width, self.size.height), [self CGImage] );
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return output;
}

@end
