//
//  UIImage+ImageCreation.h
//  victorious
//
//  Created by Will Long on 3/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageCreation)

+ (UIImage *)resizeableImageWithColor:(UIColor *)color;

/**
 Creates and returns a new image by using the receiver as a mask over
 a solid color. 
 
 @discussion
 This is the exact same thing you get if you pair
 a templated UIImage (renderingMode is AlwaysTemplate) with a tint 
 color on UIImageView. Before using this method, consider whether 
 the tintColor technique would work just as well.
 */
- (UIImage *)v_imageByMaskingImageWithColor:(UIColor *)color;

- (UIImage *)scaleToSize:(CGSize)size;

@end
