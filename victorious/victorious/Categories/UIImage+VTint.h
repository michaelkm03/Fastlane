//
//  UIImage+VTint.h
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VTint)

- (UIImage *)v_tintedImageWithColor:(UIColor *)tintColor alpha:(CGFloat)alpha blendMode:(CGBlendMode)blendMode;

- (UIImage *)v_tintedCIImageWithColor:(UIColor *)tintColor alpha:(CGFloat)alpha blendMode:(CGBlendMode)blendMode;

@end
