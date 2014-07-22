//
//  CIImage+VImage.m
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CIImage+VImage.h"

@implementation CIImage (VImage)

+ (CIImage *)v_imageWithUImage:(UIImage *)image
{
    if (image.CIImage)
    {
        return image.CIImage;
    }
    else
    {
        return [CIImage imageWithCGImage:image.CGImage];
    }
}

@end
