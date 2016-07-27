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
#import "victorious-Swift.h"

@import AVFoundation;

static const CGFloat kBlurRadius = 12.5f;
static const CGFloat kSaturationDeltaFactor = 1.8f;
static const NSTimeInterval kDefaultAnimationDuration = 0.5f;

static const char kAssociatedImageKey;
static const char kAssociatedURLKey;
static const char kAssociatedBlurredOriginalImageKey;

static NSString * const kBlurredImageCachePathExtension = @"blurred";

@implementation UIImageView (Blurring)

- (void)setBlurredImageWithClearImage:(UIImage *)image placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor
{
    UIImage *storedImage = objc_getAssociatedObject(self, &kAssociatedBlurredOriginalImageKey);
    if ([image isEqual:storedImage])
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    objc_setAssociatedObject(self, &kAssociatedBlurredOriginalImageKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.image = placeholderImage ?: self.image;
    [self blurImage:image withTintColor:tintColor toCallbackBlock:^(UIImage *blurredImage)
     {
         // If the placeholder image is still the current image, or if they are both nil
         BOOL bothImagesAreNil = (weakSelf.image == nil && placeholderImage == nil);
         if ([weakSelf.image isEqual:placeholderImage] || bothImagesAreNil)
         {
             [weakSelf animateImageToVisible:blurredImage withDuration:kDefaultAnimationDuration];
         }
     }];
}

- (void)applyTintAndBlurToImageWithURL:(NSURL *)url withTintColor:(UIColor *)tintColor
{
    if ( [self isURLDownloaded:url] )
    {
        return;
    }
    
    NSParameterAssert(!CGRectEqualToRect(self.bounds, CGRectZero));
    __weak UIImageView *weakSelf = self;
    objc_setAssociatedObject(self, &kAssociatedURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         [weakSelf blurAndAnimateImageToVisible:image
                                       cacheURL:url
                                  withTintColor:tintColor
                                    andDuration:kDefaultAnimationDuration
                       withConcurrentAnimations:nil];
     }];
}

- (void)setLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    if ( [self isURLDownloaded:url] )
    {
        return;
    }
    
    __weak UIImageView *weakSelf = self;
    self.image = placeholderImage;
    self.alpha = 0.0f;
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
                                               [weakSelf animateImageToVisible:blurredImage withDuration:kDefaultAnimationDuration];
                                           });
                        });
     }];
}

- (void)applyLightBlurAndAnimateImageWithURLToVisible:(NSURL *)url
{
    if ( [self isURLDownloaded:url] )
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
    if ( [self isURLDownloaded:url] )
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
    if ( [self isURLDownloaded:url] )
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

- (void)applyBlurToImageURL:(NSURL *)url withRadius:(CGFloat)blurRadius completion:(void (^)())callbackBlock
{
    if (url == nil)
    {
        NSAssert(false, @"The URL parameter is nil, cannot perform blur");
        return;
    }
    
    UIImage *cachedImage = [self cachedBlurredImageForURL:url andBlurRadius:blurRadius];
    if (cachedImage)
    {
        self.image = cachedImage;
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
            
            UIImage *blurredImage = [image applyBlurWithRadius:blurRadius];
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf addBlurredImage:blurredImage
                         toCacheWithURL:url
                          andBlurRadius:blurRadius];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                weakSelf.image = blurredImage;
                callbackBlock();
            });
        });
    }];
}

#pragma mark - internal helpers

- (BOOL)isURLDownloaded:(NSURL *)url
{
    return [objc_getAssociatedObject(self, &kAssociatedURLKey) isEqual:url];
}

- (void)clearDownloadCache
{
    objc_setAssociatedObject(self, &kAssociatedURLKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
             UIImageView *strongSelf = weakSelf;
             if ( strongSelf != nil && image != nil )
             {
                 //No longer displaying an image from the "blurredImageWithClearImage:" method, clear out that association
                 objc_setAssociatedObject(strongSelf, &kAssociatedBlurredOriginalImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                 objc_setAssociatedObject(strongSelf, &kAssociatedURLKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
             }
        }
         
         if ( callbackBlock != nil )
         {
             callbackBlock(image, error);
         }
     }];
}

- (void)blurAndAnimateImageToVisible:(UIImage *)image withTintColor:(UIColor *)tintColor andDuration:(NSTimeInterval)duration withConcurrentAnimations:(nullable void (^)(void))animations
{
    [self blurAndAnimateImageToVisible:image
                              cacheURL:nil
                         withTintColor:tintColor
                           andDuration:duration
              withConcurrentAnimations:animations];
}

- (void)blurAndAnimateImageToVisible:(UIImage *)image
                            cacheURL:(NSURL *)cacheURL
                       withTintColor:(UIColor *)tintColor
                         andDuration:(NSTimeInterval)duration
            withConcurrentAnimations:(void (^)(void))animations
{
    UIImage *cachedBlurredImage = [self cachedBlurredImageForURL:cacheURL andBlurRadius:kBlurRadius];
    if (cachedBlurredImage !=  nil)
    {
        if ( animations != nil )
        {
            animations();
        }
        self.image = cachedBlurredImage;
        self.alpha = 1.0f;
        return;
    }
    
    __weak UIImageView *weakSelf = self;
    if ( objc_getAssociatedObject(self, &kAssociatedBlurredOriginalImageKey) != nil )
    {
        // If we have an image set by "blurredImageWithClearImage:"
        self.alpha = 0.0f;
    }
    //No longer displaying an image from the "blurredImageWithClearImage:" method, clear out that association
    objc_setAssociatedObject(self, &kAssociatedBlurredOriginalImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    objc_setAssociatedObject(self, &kAssociatedImageKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
              if ( animations != nil )
              {
                  animations();
              }
              weakSelf.alpha = 1.0f;
          }
                          completion:^(BOOL finished)
          {
              [weakSelf addBlurredImage:blurredImage toCacheWithURL:cacheURL andBlurRadius:kBlurRadius];
          }];
     }];
}

- (void)addBlurredImage:(UIImage *)image toCacheWithURL:(NSURL *)imageURL andBlurRadius:(CGFloat)blurRadius
{
    if ( imageURL == nil )
    {
        return;
    }
    
    NSString *extension = [NSString stringWithFormat:@"%@/%f", kBlurredImageCachePathExtension, blurRadius];
    [[[SDWebImageManager sharedManager] imageCache] storeImage:image
                                                        forKey:[[imageURL URLByAppendingPathComponent:extension] absoluteString]];
}

- (UIImage *)cachedBlurredImageForURL:(NSURL *)cacheURL andBlurRadius:(CGFloat)blurRadius
{
    NSString *extension = [NSString stringWithFormat:@"%@/%f", kBlurredImageCachePathExtension, blurRadius];

    NSURL *blurredURL = cacheURL != nil ? [cacheURL URLByAppendingPathComponent:extension] : nil;
    NSString *blurredKey = [blurredURL absoluteString];
    if ( blurredKey != nil )
    {
        return [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:blurredKey];
    }
    return nil;
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
