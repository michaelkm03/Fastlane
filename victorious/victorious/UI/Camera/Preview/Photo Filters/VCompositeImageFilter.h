//
//  VCompositeImageFilter.h
//  victorious
//
//  Created by Josh Hinman on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPhotoFilterComponent.h"

#import <Foundation/Foundation.h>

/**
 Abstract base class for filters that
 composite a static image along with
 the input image.
 */
@interface VCompositeImageFilter : NSObject <VPhotoFilterComponent>

@property (nonatomic)       CGFloat   inputAlphaLevel; ///< Sets the alpha level of the gradient mask
@property (nonatomic, copy) NSString *inputBlendFilter; ///< The name of a CIFilter in the CICategoryCompositeOperation category to be used for the blending
@property (nonatomic, copy) NSString *backgroundImageName; ///< The name of an image (same rules as [UIImage imageNamed:]) to blend behind the input image
@property (nonatomic)       BOOL      flipZorder; ///< If YES, the background image goes on top of the input image.

@end
