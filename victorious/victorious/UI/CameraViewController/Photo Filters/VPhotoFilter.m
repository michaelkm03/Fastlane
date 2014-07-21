//
//  VPhotoFilter.m
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CIImage+VImage.h"
#import "VPhotoFilter.h"

@implementation VPhotoFilter

- (UIImage *)imageByFilteringImage:(UIImage *)sourceImage
{
    CIImage *filteredImage = [CIImage v_imageWithUImage:sourceImage];
    for (CIFilter *filter in self.components)
    {
        [filter setValue:filteredImage forKey:kCIInputImageKey];
        filteredImage = filter.outputImage;
    }
    return [UIImage imageWithCIImage:filteredImage];
}

@end
