//
//  AVCaptureConnection+VOrientation.m
//  victorious
//
//  Created by Josh Hinman on 9/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "AVCaptureConnection+VOrientation.h"

@implementation AVCaptureConnection (VOrientation)

- (void)v_applyDeviceOrientation:(UIDeviceOrientation)orientation
{
    if (self.supportsVideoOrientation)
    {
        switch (orientation)
        {
            case UIDeviceOrientationUnknown:
                [self setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
            case UIDeviceOrientationPortrait:
                [self setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                [self setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                break;
            case UIDeviceOrientationLandscapeLeft:
                [self setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                break;
            case UIDeviceOrientationLandscapeRight:
                [self setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
                [self setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
        }
    }
}

@end
