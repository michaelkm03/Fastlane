//
//  VBlurredImageBackground.h
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBackground.h"

extern NSString * const VBlurredImageBackgroundImageToBlurKey;

/**
 *  A blurred image background. Inject an image to blur with: VBlurredImageBackgroundImageToBlurKey.
 */
@interface VBlurredImageBackground : VBackground

/**
 *  The image (passed in via dependency management) that will be blurred.
 */
@property (nonatomic, strong, readonly) UIImage *imageToBlur;

@end
