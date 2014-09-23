//
//  AVCaptureConnection+VOrientation.h
//  victorious
//
//  Created by Josh Hinman on 9/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureConnection (VOrientation)

/**
 Translates a device orientation into an AVCaptureVideoOrientation
 and applies it to the receiver.
 */
- (void)v_applyDeviceOrientation:(UIDeviceOrientation)orientation;

@end
