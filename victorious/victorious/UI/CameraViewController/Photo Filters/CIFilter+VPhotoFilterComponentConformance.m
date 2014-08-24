//
//  CIFilter+VPhotoFilterComponentConformance.m
//  victorious
//
//  Created by Josh Hinman on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CIFilter+VPhotoFilterComponentConformance.h"

#ifdef __LP64__
#define CGFLOATVALUE doubleValue
#else
#define CGFLOATVALUE floatValue
#endif

@implementation CIFilter (VPhotoFilterComponentConformance)

- (CIImage *)imageByFilteringImage:(CIImage *)inputImage size:(CGSize)size orientation:(UIImageOrientation)orientation
{
    CGRect canvas = CGRectMake(0, 0, size.width, size.height);
    [self setValue:inputImage forKey:kCIInputImageKey];
    if ([[self inputKeys] containsObject:kCIInputCenterKey])
    {
        [self setValue:[CIVector vectorWithCGPoint:CGPointMake(CGRectGetMidX(canvas), CGRectGetMidY(canvas))] forKey:kCIInputCenterKey];
    }
    
    NSNumber *previousRadius = nil;
    if ([[self name] hasPrefix:@"CIVignette"]) // For vignette filters, convert radius from percent to absolute
    {
        previousRadius = [self valueForKey:kCIInputRadiusKey];
        [self setValue:@(previousRadius.CGFLOATVALUE * MAX(size.width, size.height)) forKeyPath:kCIInputRadiusKey];
    }
    
    CIImage *outputImage = self.outputImage;
    
    if (previousRadius)
    {
        [self setValue:previousRadius forKeyPath:kCIInputRadiusKey];
    }
    
    return outputImage;
}

@end
