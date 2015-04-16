//
//  UIImageView+Blurring.m
//  victorious
//
//  Created by Gary Philipp on 2/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Resize.h"
#import <SDWebImage/UIImageView+WebCache.h>

@import AVFoundation;

static const CGFloat kVBlurRadius = 12.5f;
static const CGFloat kVSaturationDeltaFactor = 1.8f;

@implementation UIImageView (Blurring)

- (void)setBlurredImageWithClearImage:(UIImage *)image placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor animate:(BOOL)shouldAnimate
{
    self.image = placeholderImage;
    
    __weak typeof(self) welf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       UIImage *resizedImage = [image resizedImage:AVMakeRectWithAspectRatioInsideRect(image.size, welf.bounds).size
                                              interpolationQuality:kCGInterpolationLow];
                       UIImage *blurredImage = [resizedImage applyBlurWithRadius:kVBlurRadius
                                                                       tintColor:tintColor
                                                           saturationDeltaFactor:kVSaturationDeltaFactor
                                                                       maskImage:nil];
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          welf.image = blurredImage;
                                          if (shouldAnimate)
                                          {
                                              welf.alpha = 0.0f;
                                              [UIView animateWithDuration:0.5f
                                                               animations:^
                                               {
                                                   welf.alpha = 1.0f;
                                               }];
                                          }
                                      });
                   });
}

- (void)setBlurredImageWithClearImage:(UIImage *)image placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor
{
    [self setBlurredImageWithClearImage:image placeholderImage:placeholderImage tintColor:tintColor animate:NO];
}

- (void)setBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor
{
    NSParameterAssert(!CGRectEqualToRect(self.bounds, CGRectZero));
    __weak UIImageView *weakSelf = self;

    self.alpha = 0;
    self.image = placeholderImage;
    [self sd_setImageWithURL:url
            placeholderImage:[placeholderImage applyTintEffectWithColor:tintColor]
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         [weakSelf blurAndAnimateImageToVisible:image withPlaceholderImage:placeholderImage tintColor:tintColor andDuration:0.5f];
     }];
}

- (void)blurAndAnimateImageToVisible:(UIImage *)image withPlaceholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor andDuration:(NSTimeInterval)duration
{
    self.alpha = 0;
    self.image = placeholderImage;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       UIImage *resizedImage = [image resizedImage:AVMakeRectWithAspectRatioInsideRect(image.size, self.bounds).size
                                              interpolationQuality:kCGInterpolationLow];
                       UIImage *blurredImage = [resizedImage applyBlurWithRadius:kVBlurRadius
                                                                       tintColor:tintColor
                                                           saturationDeltaFactor:kVSaturationDeltaFactor
                                                                       maskImage:nil];
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          self.image = blurredImage;
                                          [UIView animateWithDuration:duration
                                                                delay:0.0f
                                                              options:UIViewAnimationOptionCurveEaseInOut
                                                           animations:^
                                           {
                                               self.alpha = 1.0f;
                                           }
                                                           completion:nil];
                                      });
                   });
}

//TODO CAHNGE OTHER THINGS TO EXTRALIGHT
- (void)setLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    __weak UIImageView *weakSelf = self;
    [self sd_setImageWithURL:url
            placeholderImage:[placeholderImage applyLightEffect]
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        __strong UIImageView *strongSelf = weakSelf;
        strongSelf.image = [image applyLightEffect];
    }];
}

- (void)setExtraLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    __weak UIImageView *weakSelf = self;
    [self sd_setImageWithURL:url
            placeholderImage:[placeholderImage applyExtraLightEffect]
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        __strong UIImageView *strongSelf = weakSelf;
        strongSelf.image = [image applyExtraLightEffect];
    }];
}

@end
