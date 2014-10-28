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

@end
