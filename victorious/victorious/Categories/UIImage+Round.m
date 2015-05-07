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
    return [self roundedImageWithCornerRadius:cornerRadius borderWidth:0 borderColor:[UIColor whiteColor]];
}

- (UIImage *)roundedImageWithCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // Image size
    CGSize mySize = self.size;
    
    // Redraw bounds
    CGRect redrawBounds = CGRectMake(0, 0, mySize.width, mySize.height);
    
    UIGraphicsBeginImageContextWithOptions(mySize, NO, [[UIScreen mainScreen] scale]);
    
    // Add circular clip to image
    [[UIBezierPath bezierPathWithRoundedRect:redrawBounds cornerRadius:cornerRadius] addClip];
    
    // Redraw image with rounded corners in bounds
    [self drawInRect:redrawBounds];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set our border's color and width
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth * 2);
    
    // Stroke the border
    CGContextStrokeEllipseInRect(context, redrawBounds);
    
    // Get new rounded image
    UIImage *rounded =  UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rounded;
}

@end
