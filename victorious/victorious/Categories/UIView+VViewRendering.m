//
//  UIView+VViewRendering.m
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIView+VViewRendering.h"

@implementation UIView (VViewRendering)

- (void)v_renderViewWithCompletion:(ViewRenderingCompletion)completion
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       UIImage *image;
                       UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [UIScreen mainScreen].scale);
                       [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                       image = UIGraphicsGetImageFromCurrentImageContext();
                       UIGraphicsEndImageContext();
                       completion(image);
                   });
}

@end
