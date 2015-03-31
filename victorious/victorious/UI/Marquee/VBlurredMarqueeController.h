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

@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, weak) VCrossFadingImageView *crossfadingBlurredImageView;
@property (nonatomic, weak) VCrossFadingLabel *crossfadingLabel;

@end
