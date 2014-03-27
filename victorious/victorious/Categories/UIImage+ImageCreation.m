//
//  UIImage+ImageCreation.m
//  victorious
//
//  Created by Will Long on 3/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageCreation.h"

@implementation UIImage (ImageCreation)

+ (UIImage *)resizeableImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 3.0f, 3.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    return image;
}

@end
