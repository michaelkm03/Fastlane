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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        UIImage *image;
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:currentContext];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^
        {
            completion(image);
        });
    });
}

@end
