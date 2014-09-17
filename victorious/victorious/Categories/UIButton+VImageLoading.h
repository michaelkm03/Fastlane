//
//  UIButton+VImageLoading.h
//  victorious
//
//  Created by Will Long on 2/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (VImageLoading)

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
               forState:(UIControlState)state;

@end
