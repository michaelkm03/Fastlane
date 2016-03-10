//
//  VCrossFadingMarqueeLabel.h
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractCrossFadingView.h"

@class VStreamItem, VDependencyManager;

/**
    A view that creates and fades between a series of marquee caption
        labels based on the provided stream items.
 */
@interface VCrossFadingMarqueeLabel : VAbstractCrossFadingView

- (void)setupWithMarqueeItems:(NSArray *)marqueeItems;

/**
    An array of stream items whose captions or headlines will
        populate the cross fading labels as appropriate.
 */
@property (nonatomic, readonly) NSArray *marqueeItems;

/**
    The dependency manager used to style the labels contained in this view.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
