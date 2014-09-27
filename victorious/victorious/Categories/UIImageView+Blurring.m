//
//  UIImageView+Blurring.m
//  victorious
//
//  Created by Gary Philipp on 2/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"

#import <objc/runtime.h>

static const char kAssociatedObjectKey;

@implementation UIImageView (Blurring)

- (UIImage *)downloadedImage
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
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
                             strongSelf.image = [image applyBlurWithRadius:25 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
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
