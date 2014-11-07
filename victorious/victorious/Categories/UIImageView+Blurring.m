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

@import AVFoundation;

#import <objc/runtime.h>

static const char kAssociatedObjectKey;
static const CGFloat kVBlurRadius = 12.5f;
static const CGFloat kVSaturationDeltaFactor = 1.8f;

@implementation UIImageView (Blurring)

- (UIImage *)downloadedImage
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
}

- (void)setBlurredImageWithClearImage:(UIImage *)image placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor
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
                                      });
                   });
}

- (void)setBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIImageView *weakSelf = self;
    [self setImageWithURLRequest:request
                placeholderImage:placeholderImage
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                         {
                             __strong UIImageView *strongSelf = weakSelf;
                             objc_setAssociatedObject(strongSelf, &kAssociatedObjectKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                             {
                                 UIImage *resizedImage = [image resizedImage:AVMakeRectWithAspectRatioInsideRect(image.size, weakSelf.bounds).size
                                                        interpolationQuality:kCGInterpolationLow];
                                 UIImage *blurredImage = [resizedImage applyBlurWithRadius:kVBlurRadius
                                                                                 tintColor:tintColor
                                                                     saturationDeltaFactor:kVSaturationDeltaFactor
                                                                                 maskImage:nil];
                                 dispatch_async(dispatch_get_main_queue(), ^
                                 {
                                     weakSelf.alpha = 0;
                                     weakSelf.image = blurredImage;
                                     [UIView animateWithDuration:.1f animations:^
                                     {
                                         weakSelf.alpha = 1.0f;
                                     }];
                                 });
                             });
                         }
                         failure:nil];
}
//TODO CAHNGE OTHER THINGS TO EXTRALIGHT
- (void)setLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIImageView *weakSelf = self;
    [self setImageWithURLRequest:request
                placeholderImage:[placeholderImage applyLightEffect]
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         __strong UIImageView *strongSelf = weakSelf;
         strongSelf.image = [image applyLightEffect];
     }
                         failure:nil];
}

- (void)setExtraLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIImageView *weakSelf = self;
    [self setImageWithURLRequest:request
                placeholderImage:[placeholderImage applyExtraLightEffect]
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         __strong UIImageView *strongSelf = weakSelf;
         strongSelf.image = [image applyExtraLightEffect];
     }
                         failure:nil];
}

@end
