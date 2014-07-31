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

- (id)copyWithZone:(NSZone *)zone
{
    VPhotoFilter *copy = [[VPhotoFilter alloc] init];
    copy.name = self.name;
    NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:self.components.count];
    for (id component in self.components)
    {
        [components addObject:[component copy]];
    }
    copy.components = components;
    return copy;
}

- (UIImage *)imageByFilteringImage:(UIImage *)sourceImage
{
    CIImage *filteredImage = [CIImage v_imageWithUImage:sourceImage];
    for (CIFilter *filter in self.components)
    {
        [filter setValue:filteredImage forKey:kCIInputImageKey];
        filteredImage = filter.outputImage;
    }
    
    CIContext *context = [CIContext contextWithOptions:@{}];
    CGImageRef finishedImage = [context createCGImage:filteredImage
                                             fromRect:CGRectMake(0, 0, sourceImage.size.width * sourceImage.scale, sourceImage.size.height * sourceImage.scale)];
    UIImage *retVal = [UIImage imageWithCGImage:finishedImage];
    CGImageRelease(finishedImage);
    return retVal;
}

@end
