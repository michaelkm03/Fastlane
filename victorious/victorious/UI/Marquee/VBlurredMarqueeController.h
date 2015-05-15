//
//  VBlurredMarqueeController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeController.h"

@class VCrossFadingImageView, VCrossFadingLabel;

@interface VBlurredMarqueeController : VAbstractMarqueeController

- (void)animateToVisible;

@property (nonatomic, strong) VCrossFadingImageView *crossfadingBlurredImageView; ///< The imageView that will crossfade between preview images of marquee contents
@property (nonatomic, strong) VCrossFadingLabel *crossfadingLabel; ///< The label that will crossfade between the titles of marquee contents

@end
