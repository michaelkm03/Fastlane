//
//  UIImage+Masking.h
//  victorious
//
//  Created by Gary Philipp on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Masking)

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)mask;

@end
