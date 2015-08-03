//
//  UIImageView+VLoadingAnimations.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImageView+VLoadingAnimations.h"

#import "UIImageView+WebCache.h"

@implementation UIImageView (VLoadingAnimations)

- (void)fadeInImageAtURL:(NSURL *)url
{
    [self fadeInImageAtURL:url
          placeholderImage:nil];
}

- (void)fadeInImageAtURL:(NSURL *)url
        placeholderImage:(UIImage *)image
{
    [self fadeInImageAtURL:url
          placeholderImage:image
                completion:nil];
}

- (void)fadeInImageAtURL:(NSURL *)url
        placeholderImage:(UIImage *)placeholderImage
              completion:(void (^)(UIImage *))completion
{
    [self fadeInImageAtURL:url placeholderImage:placeholderImage alongsideAnimations:nil completion:completion];
}

- (void)fadeInImageAtURL:(NSURL *)url
        placeholderImage:(UIImage *)placeholderImage
     alongsideAnimations:(void (^)(void))animations
              completion:(void (^)(UIImage *))completion
{
    __weak UIImageView *weakSelf = self;
    
    [self sd_setImageWithURL:url
            placeholderImage:placeholderImage
                     options:SDWebImageRetryFailed
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if ( completion != nil )
         {
             completion( image );
         }
         
         __strong UIImageView *strongSelf = weakSelf;
         //Check if image was loaded from cache
         if ( cacheType != SDImageCacheTypeNone || ![strongSelf isValidURL:imageURL] || image == nil)
         {
             //Set image without fade animation
             strongSelf.alpha = 1.0f;
             if ( image != nil )
             {
                 strongSelf.image = image;
                 if ( animations != nil )
                 {
                     animations();
                 }
             }
             return;
         }
         
         [strongSelf fadeInImage:image alongsideAnimations:animations];
     }];
}

- (void)fadeInImage:(UIImage *)image
{
    [self fadeInImage:image alongsideAnimations:nil];
}

- (void)fadeInImage:(UIImage *)image
alongsideAnimations:(void (^)(void))animations
{
    self.alpha = 0;
    self.image = image;
    [UIView animateWithDuration:.3f animations:^
     {
         if ( animations != nil )
         {
             animations();
         }
         
         self.alpha = 1;
     }];
}

- (BOOL)isValidURL:(NSURL *)url
{
    return url != nil && ![url.absoluteString isEqualToString:@""];
}

@end
