//
//  UIImage+ImageCreation.h
//  victorious
//
//  Created by Will Long on 3/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageCreation)

+ (UIImage *)resizeableImageWithColor:(UIColor *)color;
- (UIImage *)vImageWithColor:(UIColor *)color;
- (UIImage*)scaleToSize:(CGSize)size;

@end
