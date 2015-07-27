//
//  UIImage+Resize.h
//  victorious
//
//  Created by Michael Sena on 8/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//r

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)fixOrientation;

/**
 *  Provides a transform to use when rendering this image to a bitmap.
 */
- (CGAffineTransform)transformForCurrentOrientationWithSize:(CGSize)newSize;

/**
 * Resizes the image smoothly (mip mapping) with high interpolation quality.
 */
- (UIImage *)smoothResizedImageWithNewSize:(CGSize)newSize;

/**
 *  Crops an image to what it would looko like in a square imageView with aspectFill.
 */
- (UIImage *)squareImageByCropping;

@end
