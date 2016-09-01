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
 *  Sets a blurred image to the receiving UIImageView applying any tint color and animating the image from 0.0f alpha to 1.0f over the duration parameter.
 *  If the image has already been blurred it will be cached and this method will first check the cache.
 *
 *  @param image The image to blur.
 *  @param tintColor A color to tint the image with during bluring.
 *  @param duration The duration for the fade-in animation.
 *  @param animations An block that will be executed while the blurred image is being faded in.
 */
- (void)blurAndAnimateImageToVisible:(UIImage *)image
                       withTintColor:(UIColor *)tintColor
                         andDuration:(NSTimeInterval)duration
            withConcurrentAnimations:(nullable void (^)(void))animations;

@end

NS_ASSUME_NONNULL_END
