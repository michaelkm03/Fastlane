//
//  UIImageView+Blurring.h
//  victorious
//
//  Created by Gary Philipp on 2/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Blurring)
- (void)setBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage tintColor:(UIColor *)tintColor;
- (void)setLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)setExtraLightBlurredImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;

@end
