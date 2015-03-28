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
        placeholderImage:(UIImage *)image
{
    __weak UIImageView *weakSelf = self;
    
    [self sd_setImageWithURL:url
            placeholderImage:image
                     options:SDWebImageRetryFailed
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        
        __strong UIImageView *strongSelf = weakSelf;
        //Check if image was loaded from cache
        if ( cacheType != SDImageCacheTypeNone || ![self isValidURL:imageURL] )
        {
            //Set image without fade animation
            strongSelf.image = image;
            return;
        }
        
        strongSelf.alpha = 0;
        strongSelf.image = image;
        [UIView animateWithDuration:.3f animations:^
         {
             strongSelf.alpha = 1;
         }];
        
        
    }];
    
}

- (BOOL)isValidURL:(NSURL *)url
{
    return url != nil && ![url.absoluteString isEqualToString:@""];
}

@end
