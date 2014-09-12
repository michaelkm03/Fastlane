//
//  UIImage+Masking.m
//  victorious
//
//  Created by Gary Philipp on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+Masking.h"

@implementation UIImage (Masking)

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)mask
{
    CGImageRef imageReference = image.CGImage;
    CGImageRef maskReference = mask.CGImage;
    
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference),
                                             NULL, // Decode is null
                                             YES // Should interpolate
                                             );
    
    CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
    CGImageRelease(imageMask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
    CGImageRelease(maskedReference);
    
    return maskedImage;
}

@end
