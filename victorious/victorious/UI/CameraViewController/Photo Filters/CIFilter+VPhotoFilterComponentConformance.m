//
//  CIFilter+VPhotoFilterComponentConformance.m
//  victorious
//
//  Created by Josh Hinman on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CIFilter+VPhotoFilterComponentConformance.h"

@implementation CIFilter (VPhotoFilterComponentConformance)

- (CIImage *)imageByFilteringImage:(CIImage *)inputImage size:(CGSize)size orientation:(UIImageOrientation)orientation
{
    CGRect canvas = CGRectMake(0, 0, size.width, size.height);
    [self setValue:inputImage forKey:kCIInputImageKey];
    if ([[self inputKeys] containsObject:kCIInputCenterKey])
    {
        [self setValue:[CIVector vectorWithCGPoint:CGPointMake(CGRectGetMidX(canvas), CGRectGetMidY(canvas))] forKeyPath:kCIInputCenterKey];
    }
    return self.outputImage;
}

@end
