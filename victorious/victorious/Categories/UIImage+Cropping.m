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
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize, newSize);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (self.size.width > self.size.height)
    {
        ratio = newSize / self.size.width;
        delta = (ratio * self.size.width - ratio * self.size.height);
        offset = CGPointMake(delta/2.0, 0);
    }
    else
    {
        ratio = newSize / self.size.height;
        delta = (ratio * self.size.height - ratio * self.size.width);
        offset = CGPointMake(0, delta/2.0);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * self.size.width) + delta,
                                 (ratio * self.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    }
    else
    {
        UIGraphicsBeginImageContext(sz);
    }
    
    UIRectClip(clipRect);
    [self drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
