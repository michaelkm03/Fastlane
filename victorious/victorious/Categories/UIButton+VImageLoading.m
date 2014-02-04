//
//  UIButton+VImageLoading.m
//  victorious
//
//  Created by Will Long on 2/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIButton+VImageLoading.h"

@implementation UIButton (VImageLoading)

- (void)setImageWithURL:(NSURL*)url
       placeholderImage:(UIImage *)placeholderImage
               forState:(UIControlState)state
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIButton* weakSelf = self;
    [self.imageView setImageWithURLRequest:request
                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                                   {
                                       [weakSelf setImage:image forState:state];
                                   } failure:nil];
}

@end
