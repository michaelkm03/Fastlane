//
//  UIImage+Resize.h
//  victorious
//
//  Created by Michael Sena on 8/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)fixOrientation;

/**
 *  Provides a transform to use when rendering this image to a bitmap.
 */
- (CGAffineTransform)transformForCurrentOrientationWithSize:(CGSize)newSize;

/**
 *  Scales the image, preserving aspect ratio, to a new size with a given max height or width.
 *
 *  @param maxDimension The maximum height or width of the new image.
 *  @param scaleUp If true, the image will be scaled up to meet the maximum dimension if necessary.
 */
- (UIImage *)scaledImageWithMaxDimension:(CGFloat)maxDimension upScaling:(BOOL)scaleUp;

/**
 *  Crops an image to what it would looko like in a square imageView with aspectFill.
 */
- (UIImage *)squareImageByCropping;

@end
