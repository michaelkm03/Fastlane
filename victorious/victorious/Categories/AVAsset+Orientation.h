//
//  AVAsset+Orientation.h
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AVAsset (Orientation)

/**
 The orientation of the device when the asset was recorded.
 */
@property (nonatomic, readonly) UIDeviceOrientation videoOrientation;

/**
 The required rotation for generating accurate preview images.
 */
@property (nonatomic, readonly) float previewImageRotationAdjustment;

/**
 Calculates the rotation adjustment for an arbritrary orientation
 */
+ (float)rotationAdjustmentForOrientation:(UIDeviceOrientation)orientation;

@end
