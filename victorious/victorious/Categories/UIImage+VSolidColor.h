//
//  UIImage+VSolidColor.h
//  victorious
//
//  Created by Josh Hinman on 5/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VSolidColor)

/**
 Returns a 1x1 image with the given color.
 */
+ (UIImage *)v_imageWithColor:(UIColor *)color;

@end
