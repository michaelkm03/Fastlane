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

@interface VPhotoFilter ()

@property (nonatomic, strong) NSString *description;

@end

@implementation VPhotoFilter

@synthesize description = _description;

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

- (NSString *)description
{
    if (_description == nil)
    {
        _description = [NSString stringWithFormat:@"%@, %@", [super description], self.name];
    }

    return _description;
}

- (UIImage *)imageByFilteringImage:(UIImage *)sourceImage withCIContext:(CIContext *)context
{
    CIImage *filteredImage = [self filteredImageWithInputImage:[CIImage v_imageWithUImage:sourceImage]];
    
    CGImageRef finishedImage = [context createCGImage:filteredImage fromRect:[filteredImage extent]];
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
