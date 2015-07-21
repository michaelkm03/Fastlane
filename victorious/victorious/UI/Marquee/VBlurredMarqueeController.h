//
//  VBlurredMarqueeController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeController.h"

@class VCrossFadingImageView, VCrossFadingMarqueeLabel;

/**
    An object managing the internal collection view, animations,
        and updating of views for the blurred marquee.
 */
@interface VBlurredMarqueeController : VAbstractMarqueeController

/**
    Performs the initial presentation animation, a fade in and
        content offset adjustment, if it has not already been run.
 */
- (void)animateToVisible;

/**
    The imageView that will crossfade between preview images of marquee contents.
 */
@property (nonatomic, strong) VCrossFadingImageView *crossfadingBlurredImageView;

/**
    The label that will crossfade between the titles of marquee contents.
 */
@property (nonatomic, strong) VCrossFadingMarqueeLabel *crossfadingLabel;

@end
