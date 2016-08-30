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

static const char kAssociatedImageKey;
static const char kAssociatedURLKey;
static const char kAssociatedBlurredOriginalImageKey;

static NSString * const kBlurredImageCachePathExtension = @"blurred";

@implementation UIImageView (Blurring)

#pragma mark - internal helpers

- (void)blurAndAnimateImageToVisible:(UIImage *)image
                       withTintColor:(UIColor *)tintColor
                         andDuration:(NSTimeInterval)duration
            withConcurrentAnimations:(nullable void (^)(void))animations
{
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

@end
