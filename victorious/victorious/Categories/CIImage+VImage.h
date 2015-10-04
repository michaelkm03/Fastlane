//
//  CIImage+VImage.h
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIImage (VImage)

+ (CIImage *)v_imageWithUIImage:(UIImage *)image;

@end
