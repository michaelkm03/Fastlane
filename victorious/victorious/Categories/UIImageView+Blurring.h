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

/**
 *  Sets a blurred image to the receiving UIIMageView applying any tint color and animating the image from 0.0f alpha to 1.0f over the duration parameter.
 *  If the image has already been blurred it will be cached and this method will first check the cache.
 *  Passing nil to imageURL will circumvent any cacheing and force the animation to occur.
 *
 *  @param image The image to blur.
 *  @param urlForImage A URL for the image that will be used to key off for the cache.
 *  @param tintColor A color to tint the image with during bluring.
 *  @param duration The duration for the fade-in animation.
 */
- (void)blurAndAnimateImageToVisible:(UIImage *)image
                            imageURL:(NSURL *)urlForImage
                       withTintColor:(UIColor *)tintColor
                         andDuration:(NSTimeInterval)duration;

/**
 *  Internally calls "blurAndAnimateImageToVisible:imageURL:withTintColor:andDuration:" with a nil imageURL.
 */
- (void)blurAndAnimateImageToVisible:(UIImage *)image withTintColor:(UIColor *)tintColor andDuration:(NSTimeInterval)duration;

- (void)blurImage:(UIImage *)image withTintColor:(UIColor *)tintColor toCallbackBlock:(void (^)(UIImage *))callbackBlock;

@end
