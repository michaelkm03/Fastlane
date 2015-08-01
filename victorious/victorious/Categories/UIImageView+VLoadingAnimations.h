//
//  UIImageView+VLoadingAnimations.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (VLoadingAnimations)

/**
 *  Internally calls "fadeInImageAtURL:placeholderImage:" with nil placeholder image.
 */
- (void)fadeInImageAtURL:(NSURL *)url;
- (void)fadeInImageAtURL:(NSURL *)url
        placeholderImage:(UIImage *)image;
- (void)fadeInImageAtURL:(NSURL *)url
        placeholderImage:(UIImage *)placeholderImage
              completion:(void (^)(UIImage *))completion;
- (void)fadeInImageAtURL:(NSURL *)url
        placeholderImage:(UIImage *)placeholderImage
     alongsideAnimations:(void (^)(void))animations
              completion:(void (^)(UIImage *))completion;
- (void)fadeInImage:(UIImage *)image;
- (void)fadeInImage:(UIImage *)image
alongsideAnimations:(void (^)(void))animations;

@end
