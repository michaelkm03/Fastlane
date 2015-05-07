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
    CGSize mySize = self.size;
    
    CGRect redrawBounds = CGRectMake(0, 0, mySize.width, mySize.height);
    
    // Redraw image with rounded corners
    UIGraphicsBeginImageContextWithOptions(mySize, NO, [[UIScreen mainScreen] scale]);
    
    [[UIBezierPath bezierPathWithRoundedRect:redrawBounds cornerRadius:cornerRadius] addClip];
    
    [self drawInRect:redrawBounds];
    
    UIImage *rounded = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rounded;
}

@end
