//
//  UIImageView+VLoadingAnimations.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImageView+VLoadingAnimations.h"

#import "UIImageView+AFNetworking.h"

@implementation UIImageView (VLoadingAnimations)

- (void)fadeInImageAtURL:(NSURL *)url
        placeholderImage:(UIImage *)image
{
    __weak UIImageView *weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self setImageWithURLRequest:request
                                 placeholderImage:image
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         __strong UIImageView *strongSelf = weakSelf;
         if (!request)
         {
             strongSelf.image = image;
             return;
         }
         
         strongSelf.alpha = 0;
         strongSelf.image = image;
         [UIView animateWithDuration:.3f animations:^
          {
              strongSelf.alpha = 1;
          }];
     }
                                          failure:nil
     ];
}

@end
