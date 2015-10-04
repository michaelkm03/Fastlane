//
//  CIImage+VImage.m
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CIImage+VImage.h"

@implementation CIImage (VImage)

+ (CIImage *)v_imageWithUIImage:(UIImage *)image
{
    if ( image.CIImage != nil )
    {
        return image.CIImage;
    }
    else if ( image.CGImage != nil )
    {
        return [CIImage imageWithCGImage:image.CGImage];
    }
    return nil;
}

@end
