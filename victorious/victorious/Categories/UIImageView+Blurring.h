//
//  UIImageView+Blurring.h
//  victorious
//
//  Created by Gary Philipp on 2/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Blurring)

/**
 *  Sets a blurred image in a UIImageView applying any tint color and using the placeholder until blurring is complete.
 *
 *  @param image Returns early if the new image returns YES from isEqual: to the previous image passed in as this parameter.
 *  @param placeholderImage An image to use as a placehold while blurring. May be nil.
 *  @param tintColor A color to tint the image with. May be nil.
 */
- (void)setBlurredImageWithClearImage:(UIImage *)image placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor;
- (void)applyTintAndBlurToImageWithURL:(NSURL *)url withTintColor:(UIColor *)tintColor;
- (void)setLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)applyLightBlurAndAnimateImageWithURLToVisible:(NSURL *)url;
- (void)setExtraLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)applyExtraLightBlurAndAnimateImageWithURLToVisible:(NSURL *)url;
- (void)blurAndAnimateImageToVisible:(UIImage *)image withTintColor:(UIColor *)tintColor andDuration:(NSTimeInterval)duration;
- (void)blurImage:(UIImage *)image withTintColor:(UIColor *)tintColor toCallbackBlock:(void (^)(UIImage *))callbackBlock;

@end
