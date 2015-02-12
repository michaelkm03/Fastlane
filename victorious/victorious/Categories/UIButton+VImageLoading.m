//
//  UIButton+VImageLoading.m
//  victorious
//
//  Created by Will Long on 2/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIButton+VImageLoading.h"
#import "NSString+VParseHelp.h"
#import <SDWebImage/UIButton+WebCache.h>

@implementation UIButton (VImageLoading)

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
               forState:(UIControlState)state
{
    [self setImage:placeholderImage forState:state];

    if (!url || [url.path isEmpty])
    {
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIButton *weakSelf = self;
    [self.imageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                                   {
                                       __strong UIButton *strongSelf = weakSelf;
                                       [strongSelf setImage:image forState:state];
                                   }
                                   failure:nil];
}

@end
