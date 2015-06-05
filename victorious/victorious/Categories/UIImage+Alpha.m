//
//  UIImage+Alpha.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+Alpha.h"

@implementation UIImage (Alpha)

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha
{
    UIImage *newImage;
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
        CGContextSetAlpha(ctx, alpha);
        CGContextDrawImage(ctx, area, self.CGImage);
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
