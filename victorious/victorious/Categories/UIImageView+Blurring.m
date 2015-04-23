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
#import <SDWebImage/SDWebImageManager.h>
#import <objc/runtime.h>

@import AVFoundation;

static const CGFloat kBlurRadius = 12.5f;
static const CGFloat kSaturationDeltaFactor = 1.8f;
static const NSTimeInterval kDefaultAnimationDuration = 0.5f;

static const char kAssociatedImageKey;
static const char kAssociatedURLKey;

@implementation UIImageView (Blurring)

- (void)setBlurredImageWithClearImage:(UIImage *)image placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor
{
    __weak typeof(self) weakSelf = self;
    self.image = placeholderImage;
    [self blurImage:image withTintColor:tintColor toCallbackBlock:^(UIImage *blurredImage)
     {
         weakSelf.image = blurredImage;
     }];
}

- (void)applyTintAndBlurToImageWithURL:(NSURL *)url withTintColor:(UIColor *)tintColor
{
    if ( [self alreadyDownloadedURL:url] )
    {
        return;
    }
    
    NSParameterAssert(!CGRectEqualToRect(self.bounds, CGRectZero));
    __weak UIImageView *weakSelf = self;
    objc_setAssociatedObject(self, &kAssociatedURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    self.alpha = 0;
    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         [weakSelf blurAndAnimateImageToVisible:image withTintColor:tintColor andDuration:kDefaultAnimationDuration];
     }];
}

- (void)setLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    if ( [self alreadyDownloadedURL:url] )
    {
        return;
    }
    
    __weak UIImageView *weakSelf = self;
    self.image = placeholderImage;
    [self downloadImageWithURL:url toCallbackBlock:^(UIImage *image, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            if ( error != nil )
                            {
                                weakSelf.image = nil;
                                return;
                            }
                            
                            UIImage *blurredImage = [image applyLightEffect];
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               weakSelf.image = blurredImage;
                                           });
                        });
     }];
}

- (void)applyLightBlurAndAnimateImageWithURLToVisible:(NSURL *)url
{
    if ( [self alreadyDownloadedURL:url] )
    {
        return;
    }
    
    __weak UIImageView *weakSelf = self;
    self.alpha = 0.0f;
    [self downloadImageWithURL:url toCallbackBlock:^(UIImage *image, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            if ( error != nil )
                            {
                                weakSelf.image = nil;
                                weakSelf.alpha = 1.0f;
                                return;
                            }
                            
                            UIImage *blurredImage = [image applyLightEffect];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf animateImageToVisible:blurredImage withDuration:kDefaultAnimationDuration];
                            });
                        });
     }];
}

- (void)setExtraLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    if ( [self alreadyDownloadedURL:url] )
    {
        return;
    }
    
    __weak UIImageView *weakSelf = self;
    self.image = placeholderImage;
    [self downloadImageWithURL:url toCallbackBlock:^(UIImage *image, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            if ( error != nil )
                            {
                                weakSelf.image = nil;
                                return;
                            }
                            
                            UIImage *blurredImage = [image applyExtraLightEffect];
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               weakSelf.image = blurredImage;
                                           });
                        });
     }];
}

- (void)applyExtraLightBlurAndAnimateImageWithURLToVisible:(NSURL *)url
{
    if ( [self alreadyDownloadedURL:url] )
    {
        return;
    }
    
    __weak UIImageView *weakSelf = self;
    self.alpha = 0.0f;
    [self downloadImageWithURL:url toCallbackBlock:^(UIImage *image, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            if ( error != nil )
                            {
                                weakSelf.image = nil;
                                weakSelf.alpha = 1.0f;
                                return;
                            }
                            
                            UIImage *blurredImage = [image applyExtraLightEffect];
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               [weakSelf animateImageToVisible:blurredImage withDuration:kDefaultAnimationDuration];
                                           });
                        });
     }];
}

#pragma mark - internal helpers

- (BOOL)alreadyDownloadedURL:(NSURL *)url
{
    return [objc_getAssociatedObject(self, &kAssociatedURLKey) isEqual:url];
}

- (void)downloadImageWithURL:(NSURL *)url toCallbackBlock:(void (^)(UIImage *, NSError *))callbackBlock
{
    __weak typeof(self) weakSelf = self;
    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         if ( error == nil )
         {
             objc_setAssociatedObject(weakSelf, &kAssociatedURLKey, image, OBJC_ASSOCIATION_ASSIGN);
         }
         
         if ( callbackBlock != nil )
         {
             callbackBlock(image, error);
         }
     }];
}

- (void)blurAndAnimateImageToVisible:(UIImage *)image withTintColor:(UIColor *)tintColor andDuration:(NSTimeInterval)duration
{
    __weak UIImageView *weakSelf = self;
    self.alpha = 0.0f;
    objc_setAssociatedObject(weakSelf, &kAssociatedImageKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self blurImage:image withTintColor:tintColor toCallbackBlock:^(UIImage *blurredImage)
     {
         if ( ![objc_getAssociatedObject(weakSelf, &kAssociatedImageKey) isEqual:image] )
         {
             /*
              We've finished blurring this image, but another blur request came in after it.
              Return before setting this to the blurred image to avoid setting to the wrong image.
              */
             return;
         }
         weakSelf.image = blurredImage;
         [UIView animateWithDuration:duration
                               delay:0.0f
                             options:UIViewAnimationOptionCurveEaseInOut
                          animations:^
          {
              weakSelf.alpha = 1.0f;
          }
                          completion:nil];
     }];
}

- (void)blurImage:(UIImage *)image withTintColor:(UIColor *)tintColor toCallbackBlock:(void (^)(UIImage *))callbackBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       UIImage *resizedImage = [image resizedImage:AVMakeRectWithAspectRatioInsideRect(image.size, self.bounds).size
                                              interpolationQuality:kCGInterpolationLow];
                       UIImage *blurredImage = [resizedImage applyBlurWithRadius:kBlurRadius
                                                                       tintColor:tintColor
                                                           saturationDeltaFactor:kSaturationDeltaFactor
                                                                       maskImage:nil];
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if ( callbackBlock != nil )
                                          {
                                              callbackBlock(blurredImage);
                                          }
                                      });
                   });
}

- (void)animateImageToVisible:(UIImage *)image withDuration:(NSTimeInterval)duration
{
    self.image = image;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.alpha = 1.0f;
     }
                     completion:nil];
}

@end