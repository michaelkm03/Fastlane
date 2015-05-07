//
//  UIImage+Round.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+Round.h"

@implementation UIImage (Round)

- (UIImage *)roundedImageWithCornerRadius:(CGFloat)cornerRadius
{
    // Image size
    CGSize mySize = self.size;
    
    // Redraw bounds
    CGRect redrawBounds = CGRectMake(0, 0, mySize.width, mySize.height);
    
    UIGraphicsBeginImageContextWithOptions(mySize, NO, [[UIScreen mainScreen] scale]);
    
    [[UIBezierPath bezierPathWithRoundedRect:redrawBounds cornerRadius:cornerRadius] addClip];
    
    // Redraw image with rounded corners in bounds
    [self drawInRect:redrawBounds];
    
    // Get new image
    UIImage *rounded = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rounded;
}

@end
