//
//  AVAsset+Orientation.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "AVAsset+Orientation.h"

@implementation AVAsset (Orientation)

- (UIDeviceOrientation)videoOrientation
{
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if ( tracks.count == 0 )
    {
        return UIDeviceOrientationUnknown;
    }
    
    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
    {
        return UIDeviceOrientationLandscapeLeft;
    }
    else if (txf.tx == 0 && txf.ty == 0)
    {
        return UIDeviceOrientationLandscapeRight;
    }
    else if (txf.tx == 0 && txf.ty == size.width)
    {
        return UIDeviceOrientationPortraitUpsideDown;
    }
    else
    {
        return UIDeviceOrientationPortrait;
    }
}

- (float)previewImageRotationAdjustment
{
    return [[self class] rotationAdjustmentForOrientation:self.videoOrientation];
}

+ (float)rotationAdjustmentForOrientation:(UIDeviceOrientation)orientation
{
    switch ( orientation )
    {
        case UIDeviceOrientationPortrait:
            return 90.0f;
        case UIDeviceOrientationPortraitUpsideDown:
            return -90.0f;
        case UIDeviceOrientationLandscapeLeft:
            return 180.0f;
        case UIDeviceOrientationLandscapeRight:
        default:
            return 0.0f;
    }
}

@end
