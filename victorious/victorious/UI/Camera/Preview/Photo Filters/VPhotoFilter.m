//
//  VPhotoFilter.m
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CIImage+VImage.h"
#import "VPhotoFilter.h"
#import "VPhotoFilterComponent.h"

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

- (UIImage *)imageByFilteringImage:(UIImage *)sourceImage withCIContext:(CIContext *)context
{
    CGRect canvas = CGRectMake(0, 0, sourceImage.size.width * sourceImage.scale, sourceImage.size.height * sourceImage.scale);
    CIImage *filteredImage = [CIImage v_imageWithUImage:sourceImage];
    for (id<VPhotoFilterComponent> filter in self.components)
    {
        filteredImage = [filter imageByFilteringImage:filteredImage size:canvas.size orientation:sourceImage.imageOrientation];
    }
    
    CGImageRef finishedImage = [context createCGImage:filteredImage fromRect:canvas];
    UIImage *retVal = [UIImage imageWithCGImage:finishedImage scale:sourceImage.scale orientation:sourceImage.imageOrientation];
    CGImageRelease(finishedImage);
    return retVal;
}

- (CIImage *)filteredImageWithInputImage:(CIImage *)inputImage
{
    for (id<VPhotoFilterComponent> filter in self.components)
    {
        inputImage = [filter imageByFilteringImage:inputImage 
                                              size:[inputImage extent].size
                                       orientation:UIImageOrientationUp];
    }
    return inputImage;
}

@end
