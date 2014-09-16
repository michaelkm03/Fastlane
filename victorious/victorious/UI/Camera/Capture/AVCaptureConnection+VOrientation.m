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
        AVCaptureVideoOrientation newOrientation;
        switch (orientation)
        {
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
                newOrientation = AVCaptureVideoOrientationPortrait;
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                newOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
                
            case UIDeviceOrientationLandscapeRight:
                newOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
                
            case UIDeviceOrientationUnknown:
            default:
                return;
        }
        if (self.videoOrientation != newOrientation)
        {
            self.videoOrientation = newOrientation;
        }
    }
}

@end
