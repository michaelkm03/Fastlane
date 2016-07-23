//
//  UIImageView+Blurring.h
//  victorious
//
//  Created by Gary Philipp on 2/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Blurring)

/**
 *  Sets a blurred image in a UIImageView applying any tint color and using the placeholder until blurring is complete.
 *
 *  @param image Returns early if the new image returns YES from isEqual: to the previous image passed in as this parameter.
 *  @param placeholderImage An image to use as a placehold while blurring. May be nil.
 *  @param tintColor A color to tint the image with. May be nil.
 */
- (void)setBlurredImageWithClearImage:(UIImage *)image placeholderImage:(nullable UIImage *)placeholderImage tintColor:(nullable UIColor *)tintColor;
- (void)applyTintAndBlurToImageWithURL:(NSURL *)url withTintColor:(nullable UIColor *)tintColor;
- (void)setLightBlurredImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholderImage;
- (void)applyLightBlurAndAnimateImageWithURLToVisible:(NSURL *)url;
- (void)setExtraLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)applyExtraLightBlurAndAnimateImageWithURLToVisible:(NSURL *)url;
- (void)applyBlurToImageURL:(nullable NSURL *)url withRadius:(CGFloat)blurRadius completion:(void (^)())callbackBlock;

/**
 *  Sets a blurred image to the receiving UIImageView applying any tint color and animating the image from 0.0f alpha to 1.0f over the duration parameter.
 *  If the image has already been blurred it will be cached and this method will first check the cache.
 *  Passing nil to imageURL will circumvent any cacheing and force the animation to occur.
 *
 *  @param image The image to blur.
 *  @param urlForImage A URL for the image that will be used to key off for the cache.
 *  @param tintColor A color to tint the image with during bluring.
 *  @param duration The duration for the fade-in animation.
 *  @param animations An block that will be executed while the blurred image is being faded in.
 */
- (void)blurAndAnimateImageToVisible:(UIImage *)image
                            cacheURL:(nullable NSURL *)cacheURL
                       withTintColor:(UIColor *)tintColor
                         andDuration:(NSTimeInterval)duration
            withConcurrentAnimations:(nullable void (^)(void))animations;

/**
 *  Internally calls "blurAndAnimateImageToVisible:imageURL:withTintColor:andDuration:" with a nil imageURL.
 */
- (void)blurAndAnimateImageToVisible:(UIImage *)image withTintColor:(UIColor *)tintColor andDuration:(NSTimeInterval)duration withConcurrentAnimations:(nullable void (^)(void))animations;

- (void)blurImage:(UIImage *)image withTintColor:(nullable UIColor *)tintColor toCallbackBlock:(void (^)(UIImage *))callbackBlock;

/**
 Removes any cached URL (as well as all associated objects) added to the UIImageView instance by this category.
 This is useful if you want to prevent the category from exercising an optimization that prevents re-downloading
 an image that is the same as the URL used to populated the last image.
 */
- (void)clearDownloadCache;

@end

NS_ASSUME_NONNULL_END
