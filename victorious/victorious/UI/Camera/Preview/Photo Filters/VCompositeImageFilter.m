//
//  VCompositeImageFilter.m
//  victorious
//
//  Created by Josh Hinman on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CIImage+VImage.h"
#import "VCompositeImageFilter.h"

@implementation VCompositeImageFilter

- (id)init
{
    self = [super init];
    if (self)
    {
        self.inputAlphaLevel = 1.0f;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    VCompositeImageFilter *copy = [[[self class] alloc] init];
    copy.inputAlphaLevel = self.inputAlphaLevel;
    copy.inputBlendFilter = self.inputBlendFilter;
    copy.backgroundImageName = self.backgroundImageName;
    copy.flipZorder = self.flipZorder;
    return copy;
}

- (UIImage *)backgroundImage
{
    return nil;
}

- (CIImage *)imageByFilteringImage:(CIImage *)inputImage size:(CGSize)size orientation:(UIImageOrientation)orientation
{
    UIImage *backgroundSourceImage = [UIImage imageNamed:self.backgroundImageName];
    CIImage *backgroundImage = [CIImage v_imageWithUImage:backgroundSourceImage];
    if (!backgroundImage)
    {
        return nil;
    }
    
    CIFilter *compositeFilter = [CIFilter filterWithName:self.inputBlendFilter];
    if (!compositeFilter)
    {
        return nil;
    }
    
    CIFilter *scale = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [scale setValue:backgroundImage forKey:kCIInputImageKey];
    [scale setValue:@(size.height / (backgroundSourceImage.size.height * backgroundSourceImage.scale))
             forKey:kCIInputScaleKey];
    [scale setValue:@((size.width / size.height) / (backgroundSourceImage.size.width / backgroundSourceImage.size.height))
             forKey:kCIInputAspectRatioKey];
    backgroundImage = [scale outputImage];
    
    CIFilter *alphaFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [alphaFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:self.inputAlphaLevel] forKey:@"inputAVector"];
    [alphaFilter setValue:backgroundImage forKey:kCIInputImageKey];
    backgroundImage = [alphaFilter outputImage];
    
    if (self.flipZorder)
    {
        [compositeFilter setValue:inputImage forKeyPath:kCIInputBackgroundImageKey];
        [compositeFilter setValue:backgroundImage forKey:kCIInputImageKey];
    }
    else
    {
        [compositeFilter setValue:backgroundImage forKeyPath:kCIInputBackgroundImageKey];
        [compositeFilter setValue:inputImage forKey:kCIInputImageKey];
    }
    
    return [compositeFilter outputImage];
}

@end
