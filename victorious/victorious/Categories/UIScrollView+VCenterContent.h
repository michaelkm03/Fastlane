//
//  UIScrollView+VCenterContent.h
//  victorious
//
//  Created by Michael Sena on 2/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (VCenterContent)

/**
 *  Centers the zoomed content of a scrollview.
 *  Does nothing if the scrollView's delegate does not implement viewForZoomingInScrollView:
 *
 *  @param animated Whether or not to animate.
 */
- (void)v_centerZoomedContentAnimated:(BOOL)animated;

@end
