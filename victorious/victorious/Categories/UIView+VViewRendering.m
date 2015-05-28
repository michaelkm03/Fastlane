//
//  UIView+VViewRendering.m
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIView+VViewRendering.h"

@implementation UIView (VViewRendering)

- (UIImage *)renderedView
{
    UIImage *image;
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:currentContext];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
