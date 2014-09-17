//
//  UIImage+Cropping.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+Cropping.h"

@implementation UIImage (Cropping)

- (UIImage *)squareImageScaledToSize:(CGFloat)newSize
{
    UIImage *squaredImage = [self centeredSquareImage];
    CGSize size = CGSizeMake(newSize, newSize);
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
    [squaredImage drawInRect:CGRectMake(0, 0, newSize, newSize)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

- (UIImage *)centeredSquareImage
{
    CGFloat maxSize = MIN(self.size.width, self.size.height);
    
    double x = (self.size.width - maxSize) / 2.0;
    double y = (self.size.height - maxSize) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, maxSize, maxSize);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

@end
